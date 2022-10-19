% HACOO class for sparse tensor storage.
% Working file 10/17 with parallel matrices approach
%
%HACOO methods:

classdef new_htensor
    properties
        table   %<-- hash table
        table_width
        vals %<-- values matrix
        nbuckets  %<-- number of slots in hash table
        modes   %<-- modes list
        nmodes %<-- number of modes
        depth %<-- to keep track of each bucket's chain length
        bits
        sx
        sy
        sz
        mask
        max_chain_depth
        hash_curr_size %<-- number of nnz in the hash table
        load_factor %<-- percent of the table that can be filled before rehashing
    end
    methods

        function t = new_htensor(varargin) %<-- Class constructor
            %HACOO Create a sparse tensor using HaCOO storage.
            %Parameters:
            %       modes - array of tensor modes
            % OR
            %       subs - array of nonzero tensor subscripts
            %       vals - array of nonzero values
            t.hash_curr_size = 0;
            t.load_factor = 0.6;

            switch nargin
                case 1 %<-- if we want to specify just modes
                    %fprintf('creating hacoo tensor with just modes initialized\n')
                    t.modes = varargin{1};
                    t.nmodes = length(t.modes);
                    NBUCKETS = 512;

                    % Initialize all hash table related things
                    t = hash_init(t,NBUCKETS);

                case 2 %<-- subs and vals specified
                    %fprintf('creating hacoo tensor with subs and vals initialized\n')
                    idx = varargin{1};
                    vals = varargin{2};

                    %t.modes =  max(idx{:,:}); <-- if input is a table
                    t.modes = max(idx); %<-- if input is an array
                    t.nmodes = length(t.modes);

                    nnz = size(idx,1);
                    NBUCKETS = power(2,ceil(log2(nnz/t.load_factor)));

                    % Initialize all hash table related things
                    t = hash_init(t,NBUCKETS);
                    t = t.init_vals(idx,vals);
                otherwise
                    t.modes = 0;   %<-- EMPTY class constructor
                    t.nmodes = 0;
                    NBUCKETS = 512;
                    % Initialize all hash table related things
                    t = hash_init(t,NBUCKETS);
            end
        end

        % Initialize all hash table related things
        function t = hash_init(t,n)

            t.nbuckets = n;
            %Table width may need to grow if chain depth gets bigger than 64
            t.table_width = 64;

            % create column vector w/ appropriate number of bucket slots
            %t.table = cell(t.nbuckets,1);
            t.table = zeros(t.nbuckets,t.table_width);

            %Create a parallel values matrix
            t.vals = zeros(t.nbuckets,t.table_width);

            %Array to keep track of each bucket's chain length
            t.depth = zeros(t.nbuckets,1);

            % Set hashing parameters
            t.bits = ceil(log2(t.nbuckets));
            t.sx = ceil(t.bits/8)-1;
            t.sy = 4 * t.sx-1;
            if t.sy < 1
                t.sy = 1;
            end
            t.sz = ceil(t.bits/2);
            t.mask = t.nbuckets-1;
            t.max_chain_depth = 0;
        end

        function t = init_vals(t,idx,vals)
            %{
		Set a list of subscripts and values in the sparse tensor hash table.
		Parameters:
			subs - table of nonzero subscripts
            vals - table of nonzero tensor values
		Returns:
			A hacoo data type with a populated table and value matrix. 
            Index ids are their morton encoding.
            %}

            %Apply the hash to all nonzero entries' indexes
            summed = sum(idx(:,1:end),2);
            keys = t.hash(summed);
            
            %Set everything in the table
            prog = 0;
            for i = 1:size(idx,1)
                k = keys(i);
                v = vals(i);
                si = morton_encode(idx(i,:)); %<-- original index can be recoved from the morton code

                %check if any keys are equal to 0, due to matlab indexing
                if k < 1
                    k = 1;
                end

                % We already have the index and key, insert accordingly
                if v ~= 0
                    t.table(k,t.depth(k)+1) = si;
                    t.vals(k,t.depth(k)+1) = v;
                    t.hash_curr_size = t.hash_curr_size + 1;
                    t.depth(k) = t.depth(k)+1;
                    if t.depth > t.max_chain_depth
                        t.max_chain_depth = t.depth;
                    end
                else
                    %remove entry in table
                end
                prog = prog + 1;
                if mod(prog,1000) == 0
                    disp(prog);
                end
            end

        end


        %Function to insert a nonzero entry in the hash table.
        % Input-
        %       t - The hacoo sparse tensor
        %       idx - The nonzero index array
        %       v - The nonzero value
        % Returns-
        %       t - the updated tensor.
        function t = set(t,idx,v)
            %{
            % build the modes if we need
            if t.modes == 0
                t.modes = zeros(length(i));
                t.nmodes = length(i);
            end

            % update any mode maxes as needed
            for m = 1:t.nmodes
                if t.modes(m) < i(m)
                    t.modes(m) = i(m);
                end
            end
            %}

            % find the index
            [k, i] = t.search(idx);

            % insert accordingly
            if i == -1
                if v ~= 0
                    t.table{k}{end+1} = node(idx, v);
                    t.hash_curr_size = t.hash_curr_size + 1;
                    depth = length(t.table{k});
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                end
            else
                if v ~=0
                    t.table{k}{i} = node(idx, v);
                else
                    t.remove_node(k,idx);
                end
            end

            %fprintf("index set\n");

            % Check if we need to rehash
            if((t.hash_curr_size/t.nbuckets) > t.load_factor)
                t = t.rehash();
            end

        end


        function [k,i] = search(t, idx)
            %{
		Search for an index entry in hash table.
		Parameters:
		    idx - The nonzero index to search for
		Returns:
			If m is found, it returns the (k, i) tuple where k is
			  the bucket and i is its location in the chain
			if m is not found, it returns (k, -1).
            %}
            s = sum(idx);
            k = t.hash(s);

            %b/c of MATLAB indexing...
            if k <= 0
                k = 1;
            end

            % Check if there are no entries in that bucket
            if isempty(t.table{k})
                i = -1;
                return
            end

            %attempt to find item in that slot's chain
            for i = 1:length(t.table{k})
                %fprintf('searching within chain\n');
                if isequal(t.table{k}{i}.idx_id,idx)
                    return
                end
            end
            i = -1;
            return
        end

        function item = get(t, i)
            %{
		Retrieve a tensor index. 
		Parameters:
			t - The tensor
            i - The tensor index to retrieve
		Returns:
            item - the item if found, 0.0 if not found 
            %}

            [k,j] = t.search(i);

            if j ~= -1
                %fprintf("item found");
                item = t.table{k}{j};
                return
            else
                %fprintf("item not found");
                item = 0.0;
                return
            end

            %{
            %concatenate index
            function res = cc(idx)
                res = num2str(idx);
                res = strrep(res,' ',''); %<-- remove spaces
                res = str2num(res); %<-- convert to int 
                concat_idx = uint16(res);
            end
            %}
        end
    

        function v = extract_val(t,idx)
            %{
		Retrieve the value of tensor index. 
		Parameters:
			t - The tensor
            i - The tensor index
		Returns:
            v - the tensor index's value, 0.0 if not found
            %}
            [k,j] = t.search(idx);

            if j ~= -1
                v = t.table{k}{j}.value;
                return
            else
                v = 0.0;
                return
            end
        end

        function k = hash(t, m)
            %{
		Hash the index and return the morton code and key.

		Parameters:
            t - The sparse tensor
			m - Summed index integer

		Returns:
			key
            %}
            hash = m;
            hash = hash + (bitshift(hash,t.sx)); %bit shift to the left
            hash = bitxor(hash, bitshift(hash,-t.sy)); %bit shift to the right
            hash = hash + (bitshift(hash,t.sz)); %bit shift to the left
            k = mod(hash,t.nbuckets);
        end

        % Rehash existing entries in tensor to a new tensor of a different
        % size.
        % Parameters:
        %       t - HaCOO tensor
        % Returns:
        %       r - new HaCOO tensor with rehashed entries
        function new = rehash(t)
            fprintf("Rehashing...\n");

            %gather all existing subscripts and vals into arrays
            indexes = t.all_indexes();
            vals = t.all_vals();

            %Create new tensor, constructor will fill new values into table
            new = new_htensor(indexes,vals);

            fprintf("done rehashing\n");
        end

        % Remove a nonzero entry.
        % Parameters:
        %       t - A HaCOO htensor
        %       i - the index entry to remove
        % Returns:
        %       utns - the updated HaCOO tensor
        %
        function utns = remove_node(t,i)
            [k,chain_idx] = t.search(i);

            if chain_idx ~= -1 %<-- we located the index successfully
                t.table{k}{chain_idx} = [];
                %remove the leftover blank array
                t.table{k}{chain_idx}(~cellfun('isempty',t.table{k}{chain_idx}));
                utns = t; %<-- this is not the most efficient...
            else
                fprintf("Could not remove index.\n");
                return
            end
        end

        %Returns cell array res containing all nnz index subscripts
        % in the HaCOO sparse tensor t.
        function res = all_indexes(t)
            res = cell(1,t.hash_curr_size);  %<-- preallocate array
            vi = 1; %<-- counter
            for i = 1:t.nbuckets
                for j = 1:t.table_width
                    if t.table(i,j) == 0  %<-- skip if empty
                        continue
                    else
                        %Append all the nonzeroes into an array
                        res{vi} = morton_decode(t.table(i,j),t.nmodes);
                        vi = vi+1;
                    end
                end
            end
        end


        %Returns an array v containing all nonzeroes in the sparse tensor.
        function res = all_vals(t)
            res = zeros(1,t.hash_curr_size);  %<-- preallocate array
            vi = 1; %<-- counter
            for i = 1:t.nbuckets
                for j = 1:t.table_width
                    if t.table(i,j) == 0  %<-- skip if empty
                        continue
                    else
                        %Append all the nonzeroes into an array
                        res(vi) = t.vals(i,j);
                        vi = vi+1;
                    end
                end
            end
        end

        %Save the table and values matrix to .mat file
        % file name must end in '.mat'
        function save_htns(t, file)
            A = t.table;
            save(file,'A');
        end

        %Load the table matrix from a .mat file
        function t = load_htns_table(file)
            example = matfile(file);
            t = example.A;
        end

        % Function to print all nonzero elements stored in the tensor.
        function display_htns(t)
            fprintf("Printing tensor nonzeros...\n");
            for i = 1:t.nbuckets
               for j = 1:t.table_width
                   if t.table(i,j) == 0  %<-- skip if empty
                        continue
                   else
                       idx = morton_decode(t.table(i,j),t.nmodes);
                       v = t.vals(i,j);
                       disp(idx);
                       disp(v);
                    end
               end
            end
        end

        % Clear all entries and start with a new hash table.
        function t = clear(t, nbuckets)
            t = t.hash_init(t,nbuckets);
        end

        %end of methods
    end
end