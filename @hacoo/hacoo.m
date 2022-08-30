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
            t.hash_curr_size = 0;
            t.load_factor = 0.6;
            
            if (nargin == 2) %<-- input included subs and vals
                idx = varargin{1};
                vals = varargin{2};
                t.modes = max(idx);
                t.nmodes = length(t.modes);
               
                nnz = size(idx,1);
                load_factor=0.6;
                NBUCKETS = power(2,ceil(log2(nnz/load_factor)));

            else
                t.modes = 0;   %<-- EMPTY class constructor,no modes specified
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
			subs - List of nonzero subscripts
            vals - List of nonzero tensor values
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
                si = summed_idx(i);
                
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

            morton = morton_encode(i);
            %morton = str2double(sprintf('%d', i));
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

        function mttkrp(self,u,n)
        %{
		Carry out mttkrp between the tensor and an array of matrices,
		unfolding the tensor along mode n.

		Parameters:
			u - A list of matrices, these correspond to the modes
				in the tensor, other than n. If i is the dimension in
				mode x, then u(x) must be an i x f matrix.
			n - The mode along which the tensor is unfolded for the
				product.
		Returns:
			A matrix with dimensions i_n x f
        %}
            

            % number of columns
		    fmax = size(u(1),2);
    
		    % create the result array
		    m = zeros(self.modes(n), fmax);
    
		    % go through each column
		    for f=1:fmax
			    % accumulation arrays
			    z=0;
			    t=[];
			    tind=[];
    
			    % go through every non-zero
			    for k=1:self.nbuckets
				    if isempty(self.table{k})
					    continue
                    end
				    for entry=1:length(self.table{k})
					    idx = morton_decode(self.table{k}{entry}.morton, self.nmodes);
					    t(end+1) = entry(1);
					    tind(end+1) = idx(n);
					    %z = length(t)-1;
                        z = length(t)
    
					    % multiply by the factor matrix entries
					    i=0;
					    for b=1:size(u,2)
						    % skip the unfolded mode
						    if i==n
							    i = i+1;
							    continue
                            end
    
						    % multiply the factor and advance to the next
						    t(z) = b(idx(i), f) * t(z);
						    i = i+1;
                        end
                    end
                end
			    % accumulate m(:,f)
			    for z =1:length(t)
				    m(tind(z),f) = m(tind(z), f) + t(z);
                end
   		     end
		    %return m;
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