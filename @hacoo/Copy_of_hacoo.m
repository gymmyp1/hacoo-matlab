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
        num_collisions
        max_chain_depth
        probe_time
        hash_curr_size %<-- number of nnz in the hash table
        load_factor %<-- percent of the table that can be filled before rehashing
    end
    methods

        function t = hacoo(varargin) %<-- Class constructor
            %HACOO Create a sparse tensor using HaCOO storage.
            NBUCKETS = 512;
            t.hash_curr_size = 0;
            t.load_factor = 0.6;

            % Initialize all hash table related things
            t = hash_init(t,NBUCKETS);

            if (nargin == 1)
                t.modes = varargin{1};
                t.nmodes = length(t.modes);
            else
                t.modes = 0;   %<-- EMPTY class constructor,no modes specified
                t.nmodes = 0;
            end
        end

        % Initialize all hash table related things
        function t = hash_init(t, nbuckets)
            t.nbuckets = nbuckets;

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
            t.num_collisions = 0;
            t.max_chain_depth = 0;
            t.probe_time = 0;
        end

        %Function to insert an element in the hash table. Returns the
        %updated tensor.
        function t = set(t,i,v)
            addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/morton/

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
    		%morton = morton_encode(i);
            morton = str2double(sprintf('%d', i));
    		[k, i] = t.search(morton);

    		% insert accordingly
    		if i == -1
    			if v ~= 0
    				t.table{k}{end+1} = node(morton, v);
    				t.hash_curr_size = t.hash_curr_size + 1;
    				depth = length(t.table{k});
    				if depth > t.max_chain_depth
    					t.max_chain_depth = depth;
                    end
                end
            else
    			if v ~=0
    				t.table{k}{i} = node(morton, v);
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


        function [k,i] = search(t, m)
            %{
		Search for a morton coded entry in the index hash.
		Parameters:
			m - The morton entry
		Returns:
			If m is found, it returns the (k, i) tuple where k is
			  the bucket and i is the index in the chain
			if m is not found, it returns (k, -1).
            %}
            k = t.hash(m);
            
            %this is temporary...
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
                if t.table{k}{i}.morton == m
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
            addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/morton/

            %morton = morton_encode(i);
            morton = str2double(sprintf('%d', i));
            [k,j] = t.search(morton);

            if j ~= -1
                fprintf("item found");
                item = t.table{k}{j};
                return
            else
                fprintf("item not found");
                item = 0.0;
                return
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
            t.nbuckets
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

        %Function to print all nonzero elements stored in the tensor.
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

        % Clear all entries and start w/ a new tensor.
        function t = clear(t, nbuckets)
            t = t.hash_init(t,nbuckets);
        end

        %end of methods
    end
end