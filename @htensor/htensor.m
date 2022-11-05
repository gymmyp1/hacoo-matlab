% HACOO class for sparse tensor storage.
% Working file 11/4: going to store indexes explicitly
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

                %Load from .mat file
                case 1
                    loaded = matfile(varargin{1});
                    t.table = loaded.T; %load table
                    m = loaded.M; %load table info

                    t.nbuckets = m{1};
                    t.modes = m{2};
                    t.nmodes = length(t.modes);
                    t.hash_curr_size = m{3};
                    t.max_chain_depth = m{4};
                    t.load_factor = m{5};
                    t = t.set_hashing_params();

                %Subs and vals specified as arg1 and ag2
                case 2
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
                    t = hash_init(t,NBUCKETS);
            end
        end

        % Initialize all hash table related things
        function t = hash_init(t,n)
            t.nbuckets = n;
            t.max_chain_depth = 0;
            % create column vector w/ appropriate number of bucket slots
            t.table = cell(t.nbuckets,1);

            t = t.set_hashing_params();
        end

        % Set hashing parameters
        function t = set_hashing_params(t)
            t.bits = ceil(log2(t.nbuckets));
            t.sx = ceil(t.bits/8)-1;
            t.sy = 4 * t.sx-1;
            if t.sy < 1
                t.sy = 1;
            end
            t.sz = ceil(t.bits/2);
            t.mask = t.nbuckets-1;
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

            summed_idx = cast(sum(idx,2),'int32');
            summed_idx = summed_idx';

            % hash indexes for the hash keys
            keys = arrayfun(@t.hash, summed_idx);

            %Set everything in the table
            prog = 0;
            for i = 1:size(idx,1)
                k = keys(i);
                v = vals(i);
                si = idx(i,:); %changing to explicitly storing index as is
                %si = morton_encode(idx(i,:)); %<-- store the morton code
                
                %check if any keys are equal to 0, due to matlab indexing
                if k < 1
                    k = 1;
                end

                % We already have the index and key, insert accordingly
                if v ~= 0
                    %t.table{k}{end+1} = node(si, v);
                    %if the slot is empty, create a new entry
                    if(isempty(t.table{k}))
                        t.table{k} = {si v};
                    else
                        %else concatenate the new entry vertically
                        % under existing entry
                        t.table{k} = vertcat(t.table{k},{si v});
                    end
                    t.hash_curr_size = t.hash_curr_size + 1;
                    depth = size(t.table{k},1);
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                else
                    %remove entry in table
                end
                prog = prog + 1;
                if mod(prog,10000) == 0
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
        %       t - the updated tensor
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

                    if isempty(t.table{k})
                        t.table{k} = [idx v];
                    else
                        %if not empty, append to the end
                        t.table{k} = vertcat(t.table{k},{idx v});
                    end
                    t.hash_curr_size = t.hash_curr_size + 1;
                    depth = size(t.table{k},1);
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                end
            else
                fprintf("Cannot set entry.\n");
                return
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
			  the bucket and i is its location in the chain (the row it's
              located in)
			If m is not found, it returns (k, -1).
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
            %fprintf('searching within chain\n');
            %search for the index in the first column
            for i = size(t.table{k},1)

                if t.table{k}{i} == idx
                    %return i
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
            item - matrix of [idx,val] if found, 0.0 if not found 
            %}

            [k,j] = t.search(i);

            if j ~= -1
                %fprintf("item found");
                item = t.table{k}{j,:};
                return
            else
                %fprintf("item not found");
                item = 0.0;
                return
            end
        end
    
        %Updated 11/4
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
                v = t.table{k}{j,2};
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

        % 11/4: Needs to be updated.
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
            new = htensor(indexes,vals);

            fprintf("done rehashing\n");
        end

        %11/4: Needs to be updated.
        % Remove a nonzero entry.
        % Parameters:
        %       t - A HaCOO htensor
        %       i - the index entry to remove
        % Returns:
        %       res - the updated table cell/bucket
        %
        function res = remove_node(t,i)
            [k,j] = t.search(i);

            if j ~= -1 %<-- we located the index successfully
                t.table{k}(j,:) = []; %delete the row
                res = t.table{k};
            else
                fprintf("Could not remove index.\n");
                return
            end
        end

        %Returns array 'res' containing all nonzero index subscripts
        % in the HaCOO sparse tensor t.
        function res = all_indexes(t)
            res = zeros(t.hash_curr_size,t.nmodes); %<-- preallocate matrix
            num_entries = 1;
            for i = 1:t.nbuckets
                if isempty(t.table{i})  %<-- skip bucket if empty
                    continue
                else
                    for j = 1:size(t.table{i},1)
                        res(num_entries,:) = t.table{i}{j};
                        num_entries = num_entries + 1;
                    end
                end
            end
        end


        %Returns an array 'res' containing all nonzeroes in the sparse tensor.
        function res = all_vals(t)
            res = zeros(t.hash_curr_size,1); %<-- preallocate matrix
            num_entries = 1;
            for i = 1:t.nbuckets
                if isempty(t.table{i})  %<-- skip bucket if empty
                    continue
                else
                    for j = 1:size(t.table{i},1)
                        res(num_entries) = t.table{i}{j,2};
                        num_entries = num_entries + 1;
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
                    for j = 1:size(t.table{i},1)
                        disp(t.table{i});
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