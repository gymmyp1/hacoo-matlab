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

            t.hash_curr_size = 0;
            t.load_factor = 0.6;
            t.nbuckets = 512;
    
            % Initialize all hash table related things
            t.table;  %<-- table w/ no entries
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
                t.nmodes = 0;  %<-- EMPTY class constructor
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
		hash = hash + (bitsll(hash,t.sz)); %bit shift to the left
		k = mod(hash,t.nbuckets);
        end
    end
end