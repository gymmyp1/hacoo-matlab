% HACOO class for sparse tensor storage.
%
%HACOO methods:

classdef htensor
    properties
        table   %hash table
        nbuckets  %number of slots in hash table
        modes   %modes list
        bits %hashing parameters
        sx
        sy
        sz
        mask
        max_chain_depth
        nnzLoc
        hash_curr_size %number of nnz in the hash table
        load_factor %<percent of the table that can be filled before rehashing
    end
    methods

        %{
        HACOO Create a sparse tensor using HaCOO storage.
        Parameters:
               1 argument construtors:
                   file - Load a .mat file with a HaCOO tensor that has
                   been created using write_htns() function.
                   nbuckets - create a HaCOO tensor with a specified
                   number of buckets
        
         OR
               2 argument constructors:
               subs - array of nonzero tensor subscripts
               vals - array of nonzero values
               Note: This is a very slow method due to converting
               subs to string and back again to get the concatenated
               indexes
         OR
               subs - array of nonzero tensor subscripts
               vals - array of nonzero values
               concatIdx - array of concatenated indexes
               Note: This case should be called using the read_htns()
               function.
        %}
        function t = htensor(varargin) %<-- Class constructor

            t.hash_curr_size = 0;
            t.load_factor = 0.6;

            switch nargin

                %Load from .mat file or 'nbuckets' is specified
                case 1
                    if isstring(varargin{1})
                        %load from .mat file
                        loaded = matfile(varargin{1});
                        t = loaded.t;
                        return
                    else
                        %create empty HaCOO tensor
                        t.modes = [];
                        t = t.hash_init(varargin{1});
                        return
                    end
                case 2 %Subs and vals specified as arg1 and arg2
                    %this will take a long time since it has to convert
                    %indexes to string and back. case 3 is faster

                    idx = varargin{1};
                    vals = varargin{2};

                    T = arrayfun(@string,idx);
                    X = strcat(T(:,1),'',T(:,2)); %To start the new array

                    for i=3:size(T,2)
                        X= strcat(X(:,:),'',T(:,i));
                    end

                    concatIdx = arrayfun(@str2double,X);

                    t.modes = max(idx); %<-- if input is an array

                    nnz = size(idx,1);
                    reqSize= power(2,ceil(log2(nnz/t.load_factor)));
                    NBUCKETS = max(reqSize,512);

                    % Initialize all hash table related things
                    t = t.hash_init(NBUCKETS);
                    t = t.init_table(idx,vals,concatIdx);
                    %save array of locations of nonempty buckets
                    t.nnzLoc = find(~cellfun(@isempty,t.table));
                    return

                case 3
                    idx = varargin{1};
                    vals = varargin{2};
                    concatIdx = varargin{3};

                    t.modes = max(idx);
                    nnz = size(idx,1);
                    reqSize = nnz / t.load_factor;
                    e = ceil(log2(reqSize));
                    NBUCKETS = max(512, pow2(e));

                    % Initialize all hash table related things
                    t = hash_init(t,NBUCKETS);
                    t = t.init_table(idx,vals,concatIdx);
                    %save array of locations of nonempty buckets
                    t.nnzLoc = find(~cellfun(@isempty,t.table));
                    return

                otherwise
                    t.modes = [];   %<-- EMPTY class constructor
                    NBUCKETS = 512;
                    t = hash_init(t,NBUCKETS);
                    return
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

        %{
		Set a list of subscripts and values in the sparse tensor hash table.
		Parameters:
			idx - Array of nonzero subscripts
            vals - Array of nonzero tensor values
            concatIdx - Array of nonzero subscripts that have been concatenated.

		Returns:
			A hacoo data type with a populated hash table.
        %}
        function t = init_table(t,idx,vals,concatIdx)

            keys = zeros(length(idx),1);

            for i = 1:length(idx)
                hash = concatIdx(i);
                hash = hash + bitshift(hash,t.sx);
                hash = bitxor(hash, bitshift(hash,-t.sy));
                hash = hash + bitshift(hash,t.sz);
                keys(i) = mod(hash,t.nbuckets);
            end

            keys(keys == 0) = 1;

            for i=1:length(keys)
                %check if the slot is occupied already
                if isempty(t.table{keys(i)})
                    %if not occupied already, just insert
                    t.table{keys(i)} = [idx(i,:) vals(i)];
                else
                    t.table{keys(i)} = vertcat(t.table{keys(i)},[idx(i,:) vals(i)]);
                end
                depth = size(t.table{keys(i)},1);
                if depth > t.max_chain_depth
                    t.max_chain_depth = depth;
                end
                t.hash_curr_size = t.hash_curr_size + 1;
            end
        end

        %{
        Function to insert a nonzero entry in the hash table.
         Parameters:
               t - The hacoo sparse tensor
               idx - The nonzero index array
               v - The nonzero value
         Optionally -
               update - If index already exists, update its existing
                        value by v
               concatIdx - If you have already concatenated the index,
                       then you can pass it to save the time required to convert it.
         Returns:
               t - the updated tensor
        %}
        function t = set(t,idx,v,varargin)
            % Set parameters from input or by using defaults
            params = inputParser;
            params.addParameter('update',0,@isscalar);
            params.addParameter('concatIdx',-1,@isscalar);
            params.parse(varargin{:});

            % Copy from params object
            update = params.Results.update;
            concatIdx = params.Results.concatIdx;

            % build the modes if we need to
            if isempty(t.modes) == 0
                t.modes = zeros(1,length(idx));
            end

            % update any mode maxes as needed
            for m = 1:length(t.modes)
                if t.modes(m) < idx(m)
                    t.modes(m) = idx(m);
                end
            end

            if concatIdx ~= -1
                %if a concatenated index got passed, search using that
                [k, i] = t.search(idx,'concatIdx',concatIdx);
            else
                % try to find the index
                [k, i] = t.search(idx);
            end

            % insert accordingly
            if i == -1
                %fprintf("inserting new entry\n")
                if v ~= 0
                    if isempty(t.table{k})
                        t.table{k} = [idx v];
                        %add new occupied bucket index to the end of array
                        t.nnzLoc(end+1) = k;
                    else
                        %if not empty, append to the end
                        t.table{k} = vertcat(t.table{k},[idx v]);
                    end

                    t.hash_curr_size = t.hash_curr_size + 1;
                    depth = size(t.table{k},1);
                    if depth > t.max_chain_depth
                        t.max_chain_depth = depth;
                    end
                end
            elseif update
                 %update the value instead of overwirting the existing one
                t.table{k}(i,end) = t.table{k}(i,end) + v;
            else
                fprintf("Cannot set entry.\n");
                return
            end

            % Check if we need to rehash
            if((t.hash_curr_size/t.nbuckets) > t.load_factor)
                t = t.rehash();
            end
        end

        %{
		Search for an index entry in hash table.
		Parameters:
		    idx - The nonzero index to search for
        Optional:
            concatIdx - If you already have the concatenated version of the
                index, hash using that.
		Returns:
			If m is found, it returns the (k, i) tuple where k is
			  the bucket and i is its location in the chain (the row it's
              located in)
			If m is not found, return (k, -1).
        %}
        function [k,i] = search(t, idx,varargin)
            % Set parameters from input or by using defaults
            params = inputParser;
            params.addParameter('concatIdx',-1,@isscalar);
            params.parse(varargin{:});

            % Copy from params object
            concatIdx = params.Results.concatIdx;

            %check if idx is a concatenated index or inividual index
            %components
            if concatIdx ~= -1
                %pass the concatenated index to hash function
                k = t.hash(concatIdx);
            else
                %concatenate the index
                s = num2str(idx);
                s = strrep(s,' ','');
                s = str2double(s);
                k = t.hash(s);
            end

            %ensure there are no keys equal to 0
            if k <= 0
                k = 1;
            end

            % Check if there are no entries in that bucket
            if isempty(t.table{k})
                i = -1;
                return
            else
                %attempt to find item in that bubcket's chain
                for i = 1:size(t.table{k},1)
                    if t.table{k}(i,1:end-1) == idx
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
                item = t.table{k}(end); %return the index's value
                return
            else
                %item is not found
                item = 0;
                return
            end
        end

        %{
		Hash the index and return the key.

		Parameters:
            t - The sparse tensor
			m - Concatenated index

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

        %{
        Rehash existing entries in tensor to a new tensor of double the
        existing size.
        
        Parameters:
               t - HaCOO tensor
        Returns:
               r - new HaCOO tensor with rehashed entries
        %}
        function new = rehash(t)
            %gather all existing subscripts and vals into arrays
            [subs,vals] = t.all_subsVals();

            %Create new tensor, constructor will fill new values into table
            new = htensor(subs,vals); %!! this takes a while don't have a fast way to concatenate indexes yet.
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
                t.table{k}(j,:) = []; %delete the entire row
                t.hash_curr_size = t.hash_curr_size-1;

                %if that was the only entry in that bucket, remove that key
                if size(t.table{k},1) == 0
                    t.nnzLoc = t.nnzLoc(t.nnzLoc~=k);
                end

            else
                fprintf("Could not remove nonzero entry.\n");
                return
            end
        end


        %{
            Retrieve all indexes and vals from HaCOO sparse tensor
        Parameters:
            t - HaCOO htensor
        Returns:
            subs - array of all indexes in HaCOO tensor t
            vals - array of all values in HaCOO tensor t
        %}

        function [subs,vals] = all_subsVals(t)
            A = vertcat(t.nnzLoc{1:end,:});
            subs = A(:,1:end-1);
            vals = A(:,end);
        end

        %{
        Retrieve all indexes from HaCOO sparse tensor.

        Parameters:
            t - HaCOO htensor
        Returns:
            subs - array of all indexes in HaCOO tensor t
        %}
        function subs = all_subs(t)
            A = vertcat(t.nnzLoc{1:end,:});
            subs = A(:,1:end-1);
        end


        %{
        Retrieve all values from HaCOO sparse tensor.

        Parameters:
            t - HaCOO htensor
        Returns:
            vals - array of all values in HaCOO tensor t
        %}
        function vals = all_vals(t)
            A = vertcat(t.nnzLoc{1:end,:});
            vals = A(:,end);
        end

        % Print all nonzero elements.
        function display_htns(t)
            print_limit = 100;

            if (t.hash_curr_size > print_limit)
                prompt = "The HaCOO tensor you are about to print contains more than 100 elements. Do you want to print? (Y/N): ";
                p = input(prompt,"s");
                if p  ~= "Y" || p ~= "y"
                    return
                end
            end

            nnz = t.table(t.nnzLoc);
            A = vertcat(nnz{1:end,:});
            fprintf("HaCOO tensor is size: [");
            fprintf('%g, ', t.modes(1:end-1));
            fprintf('%g]\n', t.modes(end));
            fprintf("Printing %d tensor elements.\n",t.hash_curr_size);
            disp(A);

        end

        % Clear all entries and start with a new hash table.
        function t = clear(t, nbuckets)
            t = t.hash_init(t,nbuckets);
        end


    end %end of methods
end %end class