% HACOO class for sparse tensor storage.
%
%HACOO methods:

classdef hacoo
    properties
        table   %<-- hash table
        depths  %<-- corresponding table depths
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

            t.table = cell(t.nbuckets,1); %<-- create appropriate number of bucket slots

            for i = 1:t.nbuckets %<-- create a blank list that will be populated w/ nodes in each table cell
               t.table{i} = cell(1);
            end

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

            if v == 0
                return
            end

            % find the index
            morton = morton_encode(i);
            [item, k] = t.search(morton); %search retrieves the item if found, or returns the struct where it should be if not found

            
            % insert accordingly
            if item.flag ~= -1
                %skip to the proper depth
                t.table{k}.last.next.morton = morton;
                t.table{k}.last.next.value = v;
                t.table{k}.last.next.flag = 1;
                t.table{k}.last.next.next = struct('morton',-1,'value',-1,'next',-1,'flag', -1');%<-- new dummy item at end of chain
                %update the last item
                t.table{k}.last = t.table{k}.last.next;
                t.table{k}.depth = t.table{k}.depth + 1;

                if t.table{k}.depth > t.max_chain_depth
                    t.max_chain_depth = t.table{k}.depth;
                end
            else
                %this is an unoccupied bucket
                t.table{k}.morton = morton;
                t.table{k}.value = v;
                t.table{k}.flag = 1;
                t.table{k}.depth = t.table{k}.depth + 1;
                t.table{k}.next = struct('morton',-1,'value',-1,'next',-1,'flag', -1');%<-- new dummy item at end of chain
            end

            t.hash_curr_size = t.hash_curr_size + 1;
            %fprintf("index set\n");
            

            %{
    		% Check if we need to rehash
    		if((self.hash_curr_size/self.nbuckets) > self.load_factor)
    			self.rehash();
            end
            %}
        end




        function [result,k] = search(t, m)
            %{
		Search for a morton coded entry in the index hash.
		Parameters:
			m - The morton entry
		Returns:
            result - the item if found, empty dummy struct if not found 
            k - bucket it occupies or should occupy.
            %}
            k = t.hash(m);

            for i = 1:length(t.table{k})
                if result.morton == m
                    return
                end
                result = result.next; %<-- increment thru the chain
            end
        end


        %{
		Retrieve a tensor index. 
		Parameters:
			t - The tensor
            i - The tensor index to retrieve
		Returns:
            item - the item if found, 0.0 if not found 
        %}
        function item = get(t, i)
            addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/morton/

            morton = morton_encode(i);
            item = t.search(morton);

            if item.flag == 1
                %fprintf("item found");
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

        function t = rehash(self)
            old = self.table;

            t = self.hash_init(self, self.nbuckets*2); %<-- double the number of buckets

            for i = 1:old.nbuckets %<-- loop over every bucket in old table
                if old{i}.flag == -1
                    continue
                else
                    %while no last item in chain 
                end

            end

        end

        %Function to print the tensor
        function display_tns(t)
            fprintf("Printing tensor...\n");
            for i = 1:t.nbuckets
                item = t.table{i};
                while item.flag ~= -1
                    disp(item);
                    item = item.next;
                end
            end
        end


        %end of methods
    end
end