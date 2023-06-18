% HACOO class for sparse tensor storage.
% Working file 2/15: trying out if storing morton codes impacts speed
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
        next %<-- to be able to jump to next occupied bucket
    end
    methods

        %HACOO Create a sparse tensor using HaCOO storage.
            %Parameters:
            %       modes - array of tensor modes
            % OR
            %       subs - array of nonzero tensor subscripts
            %       vals - array of nonzero values
        function t = htensor(varargin) %<-- Class constructor
            
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
                    t.next = m{6};
                    t = t.set_hashing_params();
                    t = t.init_next();

                case 2 %Subs and vals specified as arg1 and ag2
                    %{
                    %fprintf('creating hacoo tensor with subs and vals initialized\n')
                    idx = varargin{1};
                    vals = varargin{2};

                    t.modes = max(idx); %<-- if input is an array
                    t.nmodes = length(t.modes);

                    nnz = size(idx,1);
                    NBUCKETS = power(2,ceil(log2(nnz/t.load_factor)));

                    % Initialize all hash table related things
                    t = hash_init(t,NBUCKETS);
                    t = t.init_table(idx,vals);

                    %init the "next occupied bucket" flag
                    t = t.init_next();
                    %}
                
                case 3
                    %fprintf('creating hacoo tensor with subs and vals initialized\n')
                    idx = varargin{1};
                    vals = varargin{2};
                    concatIdx = varargin{3};

                    t.modes = max(idx); %<-- if input is an array
                    t.nmodes = length(t.modes);

                    nnz = size(idx,1);
                    NBUCKETS = power(2,ceil(log2(nnz/t.load_factor)));

                    % Initialize all hash table related things
                    t = hash_init(t,NBUCKETS);
                    t = t.init_table(idx,vals,concatIdx);

                    %init the "next occupied bucket" flag
                    t = t.init_next();

                otherwise
                    t.modes = [];   %<-- EMPTY class constructor
                    t.nmodes = 0;
                    NBUCKETS = 128;
                    t = hash_init(t,NBUCKETS);
            end
        end

        % Initialize all hash table related things
        function t = hash_init(t,n)
            t.nbuckets = n;
            t.max_chain_depth = 0;
            % create column vector w/ appropriate number of bucket slots +
            % 1 as a dummy bucket
            t.table = cell(t.nbuckets+1,1);

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

        %{
		Set a list of subscripts and values in the sparse tensor hash table.
		Parameters:
			idx - Array of nonzero subscripts
            vals - Array of nonzero tensor values
            concatIdx - Array of nonzero subscripts THAT HAVE BEEN CONCATENATED.

		Returns:
			A hacoo data type with a populated hash table.
        %}
        function t = init_table(t,idx,vals,concatIdx)

            keys = zeros(length(idx),1);

            for i = 1:length(idx)
               
                hash = concatIdx(i);
                hash = hash + bitshift(hash,t.sx); %bit shifting
                hash = bitxor(hash, bitshift(hash,-t.sy));
                hash = hash + bitshift(hash,t.sz);
                keys(i) = mod(hash,t.nbuckets); %mod to get the key

                %replace any keys equal to 0 to 1 since MATLAB indexes on 1
                %if key == 0
                %   key = 1;
                %end
            end

            keys(keys == 0) = 1;

            for i=1:length(keys)
                %check if the slot is occupied already
                if isempty(t.table{keys(i)})
              
                    %if not occupied already, just insert
                    t.table{keys(i)}{1} = idx(i,:);
                    t.table{keys(i)}{2} = vals(i);
                    %t.table{keys(i)}
                else
                    t.table{keys(i)} = vertcat(t.table{keys(i)},{idx(i,:) vals(i)});
                    %t.table{keys(i)}

                    depth = size(t.table{keys(i)},1);
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                end
                
                t.hash_curr_size = t.hash_curr_size + 1;
            end

            %{
            uniqueKeys = unique(keys);
            length(uniqueKeys)

            for i=1:length(uniqueKeys)
                idxLoc = find(keys == uniqueKeys(i));
                idxChunk = idx(idxLoc,:);
                valsChunk = vals(idxLoc);
                %if there are multiple entries for that bucket
                if size(idxChunk,1) == 1
                    t.table{uniqueKeys(i)} = {idxChunk vals(idxLoc)};
                else
                    %fprintf("inserting multiple entries in same bucket\n");
                    for j=1:size(idxChunk,1)
                        t.table{uniqueKeys(i)} = vertcat(t.table{uniqueKeys(i)},{idxChunk(j,:) valsChunk(j)}); 
                    end
                    depth = length(idxLoc);
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                end
                t.hash_curr_size = t.hash_curr_size + size(idxChunk,1);
            end    
            %}

            %{
            for i=1:length(keys)
                %check if the slot is occupied already
                if isempty(t.table{key})
              
                    %if not occupied already, just insert
                    t.table{key}{1} = idx(i,:);
                    t.table{key}{2} = vals(i);
                    %t.table{keys(i)}
                else
                    t.table{keys(i} = vertcat(t.table{keys(i)},{idx(i,:) vals(i)});
                    %t.table{keys(i)}

                    depth = size(t.table{keys(i)},1);
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                end
                
                t.hash_curr_size = t.hash_curr_size + 1;
            end
            %}
        end
    
        %{
          Populate "next" array that indicates the next occupied bucket
          from any occupied bucket.
        %}
        function t = init_next(t)
            t.next = zeros(t.nbuckets+1,1);
            first = 0; %if this  we have found the first occupied bucket in the table
            prev = 0; %keep track of the last occupied bucket

            t.next(t.nbuckets+1) = -1; %mark dummy bucket with flag to stop

            for i = 1:t.nbuckets

                if isempty(t.table{i})
                    if i == t.nbuckets
                        %when we get to the end of the table, mark the last ocupied bucket's "next" as dummy bucket
                        t.next(prev) = t.nbuckets+1;
                        return
                    end

                else %bucket is occupied
                    if first ~= 0
                        t.next(prev) = i;
                        prev = i; %update curr bucket to be the previous occ. bucket we've seen

                    else %if this is the first occupied bucket in the table
                        t.next(1) = i;
                        prev = i;
                        first = 1;
                    end
                end
            end
        end

        %Function to insert a nonzero entry in the hash table.
        % Input-
        %       t - The hacoo sparse tensor
        %       idx - The nonzero index array
        %       v - The nonzero value
        % Optionally -
        %       update - If index already exists, update its existing
        %                value by v
        % Returns-
        %       t - the updated tensor
        function t = set(t,idx,v,varargin)
            % Set parameters from input or by using defaults
            params = inputParser;
            params.addParameter('update',0,@isscalar);
            params.parse(varargin{:});

            % Copy from params object
            update = params.Results.update;

            % build the modes if we need to
            if t.nmodes == 0
                t.modes = zeros(length(idx));
                t.nmodes = length(idx);
            end

            % update any mode maxes as needed
            for m = 1:t.nmodes
                if t.modes(m) < idx(m)
                    t.modes(m) = idx(m);
                end
            end

            %make sure index is not invalid
            if ~all(idx)
                fprintf("Unable to insert index, which is all zeros.\n")
                return
            end

            % find the index
            [k, i] = t.search(idx);

            % insert accordingly
            if i == -1
                %fprintf("inserting new entry\n")
                if v ~= 0
                    if isempty(t.table{k})
                        t.table{k} = {idx v};
                        %t.table{k}
                    else
                        %if not empty, append to the end
                        t.table{k} = vertcat(t.table{k},{idx v});
                        %t.table{k}
                    end

                    t.hash_curr_size = t.hash_curr_size + 1;
                    depth = size(t.table{k},1);
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                end
            elseif update
                %fprintf("updating value")
                t.table{k}{i,2} = t.table{k}{i,2} + v;
            else
                fprintf("Cannot set entry.\n");
                return
            end

            %fprintf("Nonzero entry has been set: ");
            %disp(idx);

            % Check if we need to rehash
            if((t.hash_curr_size/t.nbuckets) > t.load_factor)
                t = t.rehash();
            end
        end

        %{
		Search for an index entry in hash table.
		Parameters:
		    idx - The nonzero index to search for
		Returns:
			If m is found, it returns the (k, i) tuple where k is
			  the bucket and i is its location in the chain (the row it's
              located in)
			If m is not found, return (k, -1).
        %}
        function [k,i] = search(t, idx)

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
            else
                %attempt to find item in that bubcket's chain
                %fprintf('searching within chain\n');
                for i = 1:size(t.table{k},1)
                    if t.table{k}{i} == idx
                        return
                    end
                end
            end
            i = -1;
        end

        %{
		Retrieve a tensor value.
		Parameters:
			t - The tensor
            i - The tensor index to retrieve
		Returns:
            item - the value at index i if found, 0.0 if not found 
        %}
        function item = get(t, i)

            [k,j] = t.search(i);

            if j ~= -1
                %fprintf("item found.\n");
                item = t.table{k}{j,2}; %return the index's value
                return
            else
                %fprintf("item not found.\n");
                item = 0;
                return
            end
        end

        %{
		Hash the index and return the key.

		Parameters:
            t - The sparse tensor
			m - Summed index integer

		Returns:
			k - hash key
        %}
        function k = hash(t, m)
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
            %fprintf("Rehashing...\n");

            %gather all existing subscripts and vals into arrays
            [subs,vals] = t.all_subsVals();

            %Create new tensor, constructor will fill new values into table
            new = htensor(subs,vals);
            new = new.init_next();

            %fprintf("Done rehashing,\n");
        end

        % Remove an existing tensor entry.
        % Parameters:
        %       t - A HaCOO htensor
        %       i - the index entry to remove
        % Returns:
        %       t - the updated tensor
        %
        function t = remove(t,i)
            [k,j] = t.search(i);

            if j ~= -1 %<-- we located the index successfully
                %fprintf("Deleting entry: ");
                %disp(i);
                t.table{k}(j,:) = []; %delete the entire row
            else
                fprintf("Could not remove nonzero entry.\n");
                return
            end
        end

        %Returns 2 arrays [subs,vals] containing all nonzero index subscripts
        % and their values in the HaCOO sparse tensor t.
        function [subs,vals] = all_subsVals(t)
            subs = zeros(t.hash_curr_size,t.nmodes); %<-- preallocate matrix
            vals = zeros(t.hash_curr_size,1);
            counter = 1;
            i = 1;
            while i ~= -1
                for j = 1:size(t.table{i},1)
                    subs(counter,:) = t.table{i}{j};
                    vals(counter) = t.table{i}{j,2};
                    counter = counter+1;
                end
                i = t.next(i);
            end
        end

        %Returns array 'res' containing all nonzero index subscripts
        % in the HaCOO sparse tensor t.
        function res = all_subs(t)
            res = zeros(t.hash_curr_size,t.nmodes); %<-- preallocate matrix
            counter = 1;
            i = 1;
            while i ~= -1
                for j = 1:size(t.table{i},1)
                    res(counter,:) = t.table{i}{j};
                    counter = counter+1;
                end
                i = t.next(i);
            end
        end


        %Returns an array 'res' containing all nonzeroes in the sparse tensor.
        function res = all_vals(t)
            t.hash_curr_size
            res = zeros(t.hash_curr_size,1); %<-- preallocate matrix
            counter = 1;
            i = 1;
            while i ~= -1
                for j = 1:size(t.table{i},1)
                    res(counter) = t.table{i}{j,2};
                    counter = counter+1;
                end
                i = t.next(i);
            end
        end

        %{
            Return the key of the next occupied bucket.
            
            Input:
                t - HaCOO sparse tensor
                i - index of current bucket
            Output:
                b - index of next occupied bucket
        %}
        function b = next_bucket(t,i)
            b = t.next(i);
            %fprintf("%d is %d's next bucket.\n",b, i)
        end

        %{
        Retrieve n nonzeroes from the table, beginning at start,
             which is a tuple containing [bucketIdx, rowIdx]. If an
             element is present at start, then it is included in the
             accumulation array.
         Parameters:
             t - a HaCOO tensor
             n - number of nonzeros you want to retrieve
             startBucket - The bucket at which you want to begin
                              retrieving elements
             startRow - The row/location in the chain at which you want 
                           to begin retrieving elements
          Returns:
             subs - A cell array of subscripts containing n nonzeros
             vals - An array of values corresponding to the subscripts
             bi - bucket index of the next nnz element
             li - row index of the next element past the most
                  recently counted
        %}
        function [subs,vals,bi,li] = retrieve(t, n, startBucket, startRow)
            
            subs = zeros(n,t.nmodes);
            vals = zeros(n,1);

            bi = startBucket;
            li = startRow;
            nzctr = 0;

            %Accumulate nonzero indexes and values until we reach n
            while bi ~= -1
                for li=li:size(t.table{bi},1)
                    subs(nzctr+1,:) = t.table{bi}{li};
                    vals(nzctr+1) = t.table{bi}{li,2};
                    nzctr = nzctr+1;
                    if nzctr == n
                        if li == size(t.table{bi},1) %if no more in the chain, increment bucket index and reset list index
                            bi = t.next(bi);
                            li = 1;
                            %fprintf("setting bucket index to next occ. bucket/resetting list row index\n");
                        end
                        
                        %fprintf("got enough nonzeros, return...\n");
                        return
                    end
                end

                li = 1;
                bi = t.next(bi);
            end

            %Remove any remaining rows of 0s if we run out of nnz to get.
            %fprintf("trimming zeroes...\n");
            subs = subs(1:nzctr,:);
            vals = vals(1:nzctr);
        end

        % Function to print all nonzero elements stored in the tensor.
        function display_htns(t)
            %{
            print_limit = 100;
            
            if (t.hash_curr_size > print_limit)
                prompt = "The sparse tensor you are about to print contains more than 100 elements. Do you want to print? (Y/N)";
                p = input(prompt,"s");
                if p  ~= "Y" || p ~= "y"
                    return
                end
            end
            %}

            i = 1;

            fprintf("Printing %d tensor elements.\n",t.hash_curr_size);
            fmt=[repmat('%d ',1,t.nmodes)];

            while i ~= -1
                for j = 1:size(t.table{i},1)
                    fprintf(fmt, t.table{i}{j}); %print the index
                    fprintf("%d\n",t.table{i}{j,2}); %print the value
                end
                i = t.next_bucket(i);
            end
        end

        % Clear all entries and start with a new hash table.
        function t = clear(t, nbuckets)
            t = t.hash_init(t,nbuckets);
        end


    end %end of methods
end %end class