% HACOO class for sparse tensor storage.
% Working file 9/19
%
%HACOO methods:

classdef htensor
    properties
        table   %<-- hash table
        nbuckets  %<-- number of slots in hash table
        modes   %<-- modes list
        nmodes %<-- number of modes
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

        function t = htensor(varargin) %<-- Class constructor
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

            % create column vector w/ appropriate number of bucket slots
            t.table = cell(t.nbuckets,1);

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
			subs - Table of nonzero subscripts
            vals - Table of nonzero tensor values
		Returns:
			A hacoo data type with a populated hash table.
            %}

            %{
            %Do all the processing to concatenate the indexes
            %Input- table of idx and table of vals
            idx = convertvars(idx, idx.Properties.VariableNames, 'string');

            concat_idx = rowfun(@cc, idx, 'SeparateInputs', false);
            vals = table2array(vals);
            concat_idx = table2array(concat_idx);

            % hash indexes for the hash keys
            keys = arrayfun(@t.hash, concat_idx);
            %}

            summed_idx = cast(sum(idx,2),'int32');
            summed_idx = summed_idx';

            % hash indexes for the hash keys
            keys = arrayfun(@t.hash, summed_idx);

            %Set everything in the table
            prog = 0;
            for i = 1:size(idx,1)
                k = keys(i);
                v = vals(i);
                si = idx(i,:); %<-- store the index tuple
                %si = concat_idx(i);

                %check if any keys are equal to 0, due to matlab indexing
                if k < 1
                    k = 1;
                end

                % We already have the index and key, insert accordingly
                if v ~= 0
                    t.table{k}{end+1} = node(si, v);
                    t.hash_curr_size = t.hash_curr_size + 1;
                    depth = length(t.table{k});
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                else
                    %remove entry in table
                end
                prog = prog + 1;
                if mod(prog,1000000) == 0
                    prog
                end
            end

            %{
            %concatenate index
            function res = cc(idx)
                res = join(strcat(idx)); %<-- concatenate across columns
                res = strrep(res,' ',''); %<-- remove spaces
                res = str2num(res); %<-- convert to int 
                res = uint16(res);
            end
            %}
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
            indexes = t.get_indexes();
            vals = t.get_vals();

            %Create new tensor, constructor will fill new values into table
            new = htensor(indexes,vals);

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

        %Returns array res containing all nnz index subscripts
        % in the HaCOO sparse tensor t.
        function res = get_indexes(t)
            res = zeros(t.hash_curr_size,t.nmodes); %<-- preallocate matrix
            ri = 1; %<-- counter
            for i = 1:t.nbuckets
                if isempty(t.table{i})  %<-- skip bucket if empty
                    continue
                else
                    for j = 1:length(t.table{i})
                        %Concatenate the index array into result array
                        res(ri,:) = t.table{i}{j}.idx_id;
                        ri = ri + 1;
                    end
                end
            end
        end


        %Returns an array v containing all nonzeroes in the sparse tensor.
        function v = get_vals(t)
            v = zeros(1,t.hash_curr_size);  %<-- preallocate array
            vi = 1; %<-- counter
            for i = 1:t.nbuckets
                if isempty(t.table{i})  %<-- skip bucket if empty
                    continue
                else
                    for j = 1:length(t.table{i})
                        %Append all the nonzeroes into an array
                        v(vi) = t.table{i}{j}.value;
                        vi = vi+1;
                    end
                end
            end
        end

        % Function to print all nonzero elements stored in the tensor.
        function display_htns(t)
            fprintf("Printing tensor nonzeros...\n");
            for i = 1:t.nbuckets
                %skip empty buckets
                if isempty(t.table{i})
                    continue
                else
                    for j = 1:length(t.table{i})
                        disp(t.table{i}{j});
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