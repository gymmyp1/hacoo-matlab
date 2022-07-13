% HACOO class for sparse tensor storage.
%
%HACOO methods:

classdef hacoo
    properties
        table   %<-- hash table
        nbuckets  %<--number of slots in hash table
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
        function self = hash_init(self, nbuckets)
            self.nbuckets = nbuckets;

            self.table = cell(self.nbuckets,1); %<-- create the cell table of structs
            for i = 1:self.nbuckets
               self.table{i} = struct('morton',-1,'value',-1,'next',-1,'last',-1,'depth', 0);
               self.table{i}.last = self.table{i}; %<-- set last to be the only item
            end

            self.bits = ceil(log2(self.nbuckets));
            self.sx = ceil(self.bits/8)-1;
            self.sy = 4 * self.sx-1;
            if self.sy < 1
                self.sy = 1;
            end
            self.sz = ceil(self.bits/2);
            self.mask = self.nbuckets-1;
            self.num_collisions = 0;
            self.max_chain_depth = 0;
            self.probe_time = 0;
        end

        %Function to insert an element in the hash table. Return the hash item if found, 0 if not found.
        function t = set(self,i, v)
            addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/morton/

            % build the modes if we need
            if self.modes == 0
                self.modes = zeros(length(i));
                self.nmodes = length(i);
            end

            % update any mode maxes as needed
            for m = 1:self.nmodes
                if self.modes(m) < i(m)
                    self.modes(m) = i(m);
                end
            end

            % find the index
            morton = morton_encode(i);
            [item, k] = self.search(morton); %search retrieves the item if found, -1 if not found

            % insert accordingly
            if item == -1 %<-- bucket is unoccupied, go ahead and insert
                %fprintf("bucket is unoccupied, go ahead and insert\n");
                if v ~= 0
                    self.table{k}.morton = morton;
                    self.table{k}.value = v;
                    self.table{k}.next = struct('morton',-1,'value',-1,'next',-1);%<-- insert dummy item at end of chain
                    self.table{k}.depth = self.table{k}.depth + 1;
                    self.hash_curr_size = self.hash_curr_size + 1;

                    if self.table{k}.depth > self.max_chain_depth
                        self.max_chain_depth = self.table{k}.depth;
                    end
                    fprintf("index set\n");
                end
            else %<-- entry goes in an existing list
                if v ~=0
                    new_item = self.table{k}.last.next;
                    new_item.morton = morton; %<-- update the dummy item at the end
                    new_item.value = v;
                    new_item.next = struct('morton',-1,'value',-1,'next',-1);%<-- new dummy item at end of chain
                    self.table{k}.depth = self.table{k}.depth + 1;
                    self.hash_curr_size = self.hash_curr_size + 1;
                    self.table{k}.last = new_item; %<-- update the last item
                else
                    %self.remove(k,i); %not implemented yet
                end
                
            end

            %{
    		% Check if we need to rehash
    		if((self.hash_curr_size/self.nbuckets) > self.load_factor)
    			self.rehash();
            end
            %}
            t = self;
        end

        function [result,k] = search(self, m)
            %{
		Search for a morton coded entry in the index hash.
		Parameters:
			m - The morton entry
		Returns:
            result - the item if found, -1 if not found 
            k - bucket it occupies or should occupy.
            %}
            k = self.hash(m);
            curr_item = self.table{k};
            while curr_item.morton ~= -1 %<-- check if there's a next element in chain
                if curr_item.morton == m
                    result = curr_item;
                    return
                end
                curr_item = curr_item.next; %<-- increment thru the chain
                k = k+1;
            end
            result = -1; %<-- item was not found
            return;
        end

        function item = get(self, i) %<-- working here
            addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/morton/

            morton = morton_encode(i);
            [item, k] = self.search(morton);

            if item.morton ~= -1 %<-- return the item if it is present
                %fprintf("item found");
                return
            else
                %fprintf("item not found");
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

            for i = 1:length(old) %<-- loop over every bucket in old table
                if old{i}.morton == -1
                    continue
                end
                %this may need to be refactored...
                while old{i}.morton ~= -1 %<-- loop over every item in the chain
                    k = self.hash(t, old{i}.morton); %<-- return new key for this item
                    if self.table{k}.morton == -1 %<-- If slot is unoccupied, go ahead and insert.
                        self.table{k}.morton = morton;
                        self.table{k}.value = v;
                        self.table{k}.next = struct('morton',-1,'value',-1,'next',-1);%<-- insert dummy item at end of chain
                        self.table{k}.depth = self.table{k}.depth + 1;
                        self.hash_curr_size = self.hash_curr_size + 1;

                        if self.table{k}.depth > self.max_chain_depth
                            self.max_chain_depth = self.table{k}.depth;
                        end
                    else
                        new_item = self.table{k}.last.next;
                        new_item.morton = morton; %<-- update the dummy item at the end
                        new_item.value = v;
                        new_item.next = struct('morton',-1,'value',-1,'next',-1);%<-- new dummy item at end of chain
                        self.table{k}.depth = self.table{k}.depth + 1;
                        self.hash_curr_size = self.hash_curr_size + 1;
                        self.table{k}.last = new_item; %<-- update the last item
                    end
                end
            end

        end
        
        %Function to print the tensor
        function display_tns(self)
            for i = 1:self.nbuckets
                curr_item = self.table{i};
                if curr_item.morton == -1
                    %fprintf("empty bucket, skipping\n");
                    continue
                else
                    fprintf("occupied bucket, printing\n");
                    curr_item
                    while curr_item.next ~= -1
                        curr_item = curr_item.next;
                        curr_item
                    end
                end
            end
        end

        %end of methods
    end
end