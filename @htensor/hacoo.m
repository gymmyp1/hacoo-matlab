% HACOO class for sparse tensor storage.
%
%HACOO methods:

classdef hacoo
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

        function t = hacoo(varargin) %<-- Class constructor
            %HACOO Create a sparse tensor using HaCOO storage.
            %Expects input to be: table of subs, table of vals
            t.hash_curr_size = 0;
            t.load_factor = 0.6;
            
            if (nargin == 2) %<-- input params
                idx = varargin{1};
                vals = varargin{2};

                t.modes =  max(idx{:,:});
                t.nmodes = length(t.modes);
               
                nnz = size(idx,1);
                load_factor=0.6;
                NBUCKETS = power(2,ceil(log2(nnz/load_factor)));

            else
                t.modes = 0;   %<-- EMPTY class constructor
                t.nmodes = 0;
                NBUCKETS = 512;
            end

            % Initialize all hash table related things
            t = hash_init(t,NBUCKETS);
            t = t.init_vals(idx,vals);
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

            %Do all the processing to concatenate the indexes
            idx = convertvars(idx, idx.Properties.VariableNames, 'string');

            
            concat_idx = rowfun(@cc, idx, 'SeparateInputs', false);
            vals = table2array(vals);
            concat_idx = table2array(concat_idx);

            % hash indexes for the hash keys
            keys = arrayfun(@t.hash, concat_idx);

            %Set everything in the table
            prog = 0;
            for i = 1:size(idx,1)
                k = keys(i);
                v = vals(i);
                si = concat_idx(i);
               
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
                if mod(prog,10000) == 0
                    prog
                end
            end

            %concatenate index
            function res = cc(idx)
                res = join(strcat(idx)); %<-- concatenate across columns
                res = strrep(res,' ',''); %<-- remove spaces
                res = str2num(res); %<-- convert to int 
                res = uint16(res);
            end
        end


        %Function to insert an element in the hash table. Returns the
        %updated tensor.
        function t = set(t,i,v)

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

            % find the index
    		morton_id = morton_encode(i); %actual id to search for index
            morton = str2double(sprintf('%d', i)); %not really morton anymore, this is used for hashing
    		[k, i] = t.search(morton);

    		% insert accordingly
    		if i == -1
    			if v ~= 0
    				t.table{k}{end+1} = node(morton_id, v);
    				t.hash_curr_size = t.hash_curr_size + 1;
    				depth = length(t.table{k});
    				if depth > t.max_chain_depth
    					t.max_chain_depth = depth;
                    end
                end
            else
    			if v ~=0
    				t.table{k}{i} = node(morton_id, v);
                else
    				t.remove_node(k,i);
                end
            end

            %fprintf("index set\n");
            
    		% Check if we need to rehash
    		if((t.hash_curr_size/t.nbuckets) > t.load_factor)
    			t = t.rehash();
            end
            
        end


        function [k,i] = search(t, c)
            %{
		Search for a morton coded entry in the index hash.
		Parameters:
		    c - The concatenated index entry
		Returns:
			If m is found, it returns the (k, i) tuple where k is
			  the bucket and i is the index in the chain
			if m is not found, it returns (k, -1).
            %}
            k = t.hash(c);
            
            %b/c of MATLAB indexing...
            if k <= 0
                k = 1;
            end

            %check if there are no entries in that bucket
            if isempty(t.table{k})
                i = -1;
                return
            end

            %attempt to find item in that slot's chain
            for i = 1:length(t.table{k})
                %fprintf('searching within chain\n');
                if t.table{k}{i}.morton == c
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


            idx = cc(i);

            [k,j] = t.search(idx);

            if j ~= -1
                %fprintf("item found");
                item = t.table{k}{j};
                return
            else
                %fprintf("item not found");
                item = 0.0;
                return
            end

            %concatenate index
            function res = cc(idx)
                res = num2str(idx);
                res = strrep(res,' ',''); %<-- remove spaces
                res = str2num(res); %<-- convert to int 
                concat_idx = uint16(res);
            end
        end

        function k = hash(t, m)
            %{
		Hash the index and return the morton code and key.

		Parameters:
            t - The sparse tensor
			m - The morton code to hash

		Returns:
			key
            %}
            hash = m;
            hash = hash + (bitshift(hash,t.sx)); %bit shift to the left
            hash = bitxor(hash, bitshift(hash,-t.sy)); %bit shift to the right
            hash = hash + (bitshift(hash,t.sz)); %bit shift to the left
            k = mod(hash,t.nbuckets);
        end

        function t = rehash(t)
            fprintf("Rehashing...\n");
            old = t.table;

            t = t.hash_init(t.nbuckets*2); %<-- double the number of buckets
            %t.nbuckets
            % reinsert everything into the hash index
    		for i = 1:length(old)
    			if isempty(old{i})
    				continue
                end
    			for j = 1:length(old{i})
    				k = t.hash(old{i}{j}.morton);
                    
                    if k <= 0
                        k = 1;
                    end
                    
    				t.table{k}{end+1} = old{i}{j};
    				depth = length(t.table{k});
    				if depth > t.max_chain_depth
    					t.max_chain_depth = depth;
                    end
                end
            end
            fprintf("done rehashing\n");
        end

        function t = remove_node(t,k,i)
            %need to find the element to remove, then slide back all data after that
            % and resize the cell array
            fprintf("not implemented yet\n");
        end

        function m = size(X)
            %Returns tensor X's modes.
            m = X.modes;
        end

        function write_tns(t,file)
            %{
                Write a sparse tensor to a file using HaCOO file format:
            
                Format: morton_id value hash_key
                (subsequent entries w/ same hash key belong in corresponding order in the
                chain)
            %}
            fprintf("Writing tensor...\n");
            fileID = fopen(file,'w');

            for i = 1:t.nbuckets
                for j = 1:length(t.table{i})
                    if t.table{i}{j}.morton ~= -1
                        fprintf(fileID,'%d %f %d\n',t.table{i}{j}.morton,t.table{i}{j}.value,i);
                    end
                end
            end
            fclose(fileID);
            fprintf("Finished.\n");
        end


        % Function to print all nonzero elements stored in the tensor.
        function display_tns(t)
            fprintf("Printing tensor...\n");
            for i = 1:t.nbuckets
                for j = 1:length(t.table{i})
                    if t.table{i}{j}.morton ~= -1
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