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
            t.nbuckets = NBUCKETS;

            t.table = cell(t.nbuckets,1); %<-- create the cell table of structs
            for i = 1:t.nbuckets
                t.table{i} = struct('morton',-1,'value',-1,'next',-1);
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

            if (nargin == 1)
                t.modes = varargin{1};
                t.nmodes = length(t.modes);
            else
                t.modes = 0;   %<-- EMPTY class constructor,no modes specified
                t.nmodes = 0;
            end
        end

        %Function to insert an element in the hash table. Return the hash item if found, 0 if not found.
        function t = set(self,i, v)
            addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/morton/

            % build the modes if we need
            if self.modes == 0
                self.modes = zeroes(length(i));
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
            [k, i] = self.search(morton);

            % insert accordingly
            if i == -1 %<-- bucket is unoccupied, go ahead and insert
                fprintf("bucket is unoccupied, go ahead and insert\n");
                if v ~= 0
                    self.table{k}.morton = morton;
                    self.table{k}.value = v;
                    self.table{k}.next = struct('morton',-1,'value',-1,'next',-1);
                    self.hash_curr_size = self.hash_curr_size + 1;
                    %depth = length(self.table(k));
                    %if depth > self.max_chain_depth
                    %    self.max_chain_depth = depth;
                    %end
                    fprintf("index set\n");
                end
            else %<-- entry goes in an existing list
                if v ~=0
                    curr_item = self.table{k};
                    while curr_item.morton ~= -1 %<-- iterate to the end of the chain
                        curr_item = self.table{k}.next; %<-- increment thru the chain
                    end
                    curr_item.next.morton = morton; %<-- insert new item at end of chain
                    curr_item.next.value = v;
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
        end

        function [k,i] = search(self, m) %<-- does this need to return the item itself?
            %{
		Search for a morton coded entry in the index hash.
		Parameters:
			m - The morton entry
		Returns:
			If m is found, it returns the (k, i) tuple where k is
			  the bucket and i is the index in the chain
			if m is not found, it returns (k, -1).
            %}
            k = self.hash(m);
            if self.table{k}.morton ~= -1 %<-- check if that whole slot is not empty
                i = 1;
                item = self.table{k};
                while item.next ~= -1 %<-- check if there's a next element in chain
                    if item.morton == m
                        return
                    end
                    item = item.next; %<-- increment thru the chain
                    i = i+1;
                end
            end
            i = -1; %<-- item was not found
            return;
        end

        function item = get(self, i) %<-- working here
            morton = mort.encode(*i);
            k, i = self.search(morton);


    		if i ~= -1 %<-- return the item if it is present
    			return
            else
    			return 0.0
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
    end
end