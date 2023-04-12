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
                    %NBUCKETS = 512;
                    NBUCKETS = 128;
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
			subs - Array of nonzero subscripts
            vals - Array of nonzero tensor values
		Returns:
			A hacoo data type with a populated hash table.
            %}

            %Sum every row
            S = sum(idx,2);
            shift1 = arrayfun(@(x) x + bitshift(x,t.sx),S);
            shift2 = arrayfun(@(x) bitxor(x, bitshift(x,-t.sy)),shift1);
            shift3 = arrayfun(@(x) x + bitshift(x,t.sz),shift2);
            keys =  arrayfun(@(x) mod(x,t.nbuckets),shift3);

            %replace any keys equal to 0 to 1 b/c of MATLAB indexing
            keys(keys==0) = 1;

            uniqueKeys = unique(keys);

            for i = 1:length(uniqueKeys)
                idxLoc  = find(keys == uniqueKeys(i));
                chunk = idx(idxLoc,:);
                t.table{uniqueKeys(i)} = {chunk vals(idxLoc)};

                depth = length(idxLoc);
                if depth > t.max_chain_depth
                    t.max_chain_depth = depth;
                end
                t.hash_curr_size = t.hash_curr_size + depth;
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


            % find the index
            [k, i] = t.search(idx);

            % insert accordingly
            if i == -1
                if v ~= 0

                    if isempty(t.table{k})
                        t.table{k} = {idx v};
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
            elseif update
                %t.table{k}{2}(j) = t.table{k}{2}(j) + v;
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

            return;
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
            else

                %attempt to find item in that bubcket's chain
                %fprintf('searching within chain\n');
                for i = 1:size(t.table{k}{1},1)
                    if t.table{k}{1}(i,:) == idx
                        return
                    end
                end
            end
            i = -1;
        end

        %as of now this does the same thing as extract_val()...
        function item = get(t, i)
            %{
		Retrieve a tensor value.
		Parameters:
			t - The tensor
            i - The tensor index to retrieve
		Returns:
            item - the value at index i if found, 0.0 if not found 
            %}

            [k,j] = t.search(i);

            if j ~= -1
                %fprintf("item found.\n");
                item = t.table{k}{2}(j);
                return
            else
                %fprintf("item not found.\n");
                item = 0.0;
                return
            end
        end


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
                v = t.table{k}{2}(j);
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

        % Rehash existing entries in tensor to a new tensor of a different
        % size.
        % Parameters:
        %       t - HaCOO tensor
        % Returns:
        %       r - new HaCOO tensor with rehashed entries
        function new = rehash(t)
            %fprintf("Rehashing...\n");

            %gather all existing subscripts and vals into arrays
            indexes = t.all_subs();
            vals = t.all_vals();

            %Create new tensor, constructor will fill new values into table
            new = htensor(indexes,vals);

            %fprintf("Done rehashing,\n");
        end

        % Remove a nonzero entry.
        % Parameters:
        %       t - A HaCOO htensor
        %       i - the index entry to remove
        % Returns:
        %       t - the updated tensor
        %
        function t = remove(t,i)
            [k,j] = t.search(i);

            if j ~= -1 %<-- we located the index successfully
                fprintf("Deleting entry: ");
                %disp(i);
                t.table{k}{1}(j,:) = []; %delete the row in the index cell array
                t.table{k}{2}(j) = []; %delete the row in the value array
            else
                fprintf("Could not remove nonzero entry.\n");
                return
            end
        end

        %Returns array 'res' containing all nonzero index subscripts
        % in the HaCOO sparse tensor t.
        function res = all_subs(t)
            res = zeros(t.hash_curr_size,t.nmodes); %<-- preallocate matrix
            cnt = 1;
            for i = 1:t.nbuckets
                if isempty(t.table{i})  %<-- skip bucket if empty
                    continue
                else
                    len = size(t.table{i}{1},1);
                    if len == 1
                        %Just copy over that 1 row
                        res(cnt,:) = t.table{i}{1};
                    else
                        res(cnt:cnt+len-1,:) = t.table{i}{1};
                    end
                    cnt = cnt + len;
                end
            end
        end


        %Returns an array 'res' containing all nonzeroes in the sparse tensor.
        function res = all_vals(t)
            res = zeros(t.hash_curr_size,1); %<-- preallocate matrix
            cnt = 1;
            for i = 1:t.nbuckets
                if isempty(t.table{i})  %<-- skip bucket if empty
                    continue
                else
                    len = length(t.table{i}{2});
                    if len == 1
                        %Just copy over that 1 row
                        res(cnt) = t.table{i}{2};
                    else
                        res(cnt:cnt+len-1) = t.table{i}{2};
                    end
                    cnt = cnt + len;
                end
            end
        end

        function V = htns_coo_mttkrp(X,U,n,nzchunk,rchunk,ver)
            %MTTKRP Matricized tensor times Khatri-Rao product for sparse tensor.
            %   This has been adapted to use sub and val matrices extracted from
            %   a HaCOO/htensor.
            %
            %   NOTICE: This internals of this code changed in Version 3.3 of Tensor
            %   Toolbox to be much more efficient. It now "chunks" the nonzeros as well
            %   as the factor matrices. Special options for this are described below.
            %
            %   V = MTTKRP(X,U,N) efficiently calculates the matrix product of the
            %   n-mode matricization of X with the Khatri-Rao product of all
            %   entries in U, a cell array of matrices, except the Nth.  How to
            %   most efficiently do this computation depends on the type of tensor
            %   involved.
            %
            %   V = MTTKRP(X,K,N) instead uses the Khatri-Rao product formed by the
            %   matrices and lambda vector stored in the ktensor K. As with the cell
            %   array, it ignores the Nth factor matrix. The lambda vector is absorbed
            %   into one of the factor matrices.
            %
            %   V = MTTKRP(X,U,N,0) reverts to the OLD version of MTTKRP prior to
            %   Tensor Toolbox Version 3.3, which repeatedly calls TTV.
            %
            %   V = MTTKRP(X,U,N,NZCHUNK,RCHUNK) specifies the "chunk" sizes for the
            %   nonzeros and factor matrix columns, respectively. These default to
            %   NZCHUNK=1e4 and RCHUNK=10 if not specified. If NZCHUNK=NNZ(X) and
            %   RCHUNCK=SIZE(U{1},2), then it's just one big chunk.
            %
            %   V = MTTKRP(X,U,N,NZCHUNK,RCHUNK,2) swaps the loop order so that the
            %   R-loop is INSIDE the NZ-loop rather than the reverse, which is the
            %   default.
            %
            %   Examples
            %   S = sptensor([3 3 3; 1 3 3; 1 2 1], 4, [3, 4, 3]); %<-Declare sptensor
            %   mttkrp(S, {rand(3,3), rand(3,3), rand(3,3)}, 2)
            %
            %   See also TENSOR/MTTKRP, SPTENSOR/TTV, SPTENSOR
            %
            %Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>

            % In the sparse case, we do not want to form the Khatri-Rao product.

            N = X.nmodes;

            if isa(U,'ktensor')
                % Absorb lambda into one of the factors, but not the one that's skipped
                if n == 1
                    U = redistribute(U,2);
                else
                    U = redistribute(U,1);
                end
                % Extract the factor matrices
                U = U.u;
            end

            if (length(U) ~= N)
                error('Cell array is the wrong length');
            end

            if ~iscell(U)
                error('Second argument should be a cell array or a ktensor');
            end

            if (n == 1)
                R = size(U{2},2);
            else
                R = size(U{1},2);
            end

            if ~exist('nzchunk','var')
                nzchunk = 1e4;
            end
            if ~exist('rchunk','var')
                rchunk = 10;
            end
            if ~exist('ver','var')
                if nzchunk <= 0
                    ver = 0;
                else
                    ver = 1;
                end
            end


            if ver == 0 % OLD WAY

                V = zeros(size(X,n),R);

                for r = 1:R
                    % Set up cell array with appropriate vectors for ttv multiplication
                    Z = cell(N,1);
                    for i = [1:n-1,n+1:N]
                        Z{i} = U{i}(:,r);
                    end
                    % Perform ttv multiplication
                    V(:,r) = double(ttv(X, Z, -n));
                end

            elseif ver == 1 % NEW DEFAULT 'CHUNKED' APPROACH
                %fprintf("using chunked approach...\n");

                nz = X.hash_curr_size;
                d = X.nmodes;
                nn = X.modes(n);
                startBucket = 1;
                startRow = 1;

                V = zeros(nn,R);
                rctr = 0;
                while (rctr < R)

                    % Process r range from rctr1 to rctr (columns of factor matrices)
                    rctr1 = rctr + 1;
                    rctr = min(R, rctr + rchunk);
                    rlen = rctr - rctr1 + 1;

                    nzctr = 0;
                    while (nzctr < nz)

                        % Process nonzero range from nzctr1 to nzctr
                        nzctr1 = nzctr+1;
                        nzctr = min(nz,nzctr1+nzchunk);
                        
                        % ----
                        [subs,vals,stopBucket,stopRow] = X.retrieve(nzctr-nzctr1+1,startBucket,startRow);
                        %size(subs,1)
                        %size(subs,2)
                        
                        %size(vals,1)
                        %size(vals,2)
                        %size(subs(nzctr1:nzctr),1);
                        %size(subs(nzctr1:nzctr),2);
                        %size(vals(nzctr1:nzctr),1);
                        %size(vals(nzctr1:nzctr),2);
                        %nzctr1
                        %nzctr
                        %Vexp = repmat(vals(nzctr1:nzctr),1,rlen);
                        Vexp = repmat(vals,1,rlen);
                        size(Vexp,1)
                        size(Vexp,2)
                        for k = [1:n-1, n+1:d]
                            Ak = U{k};
                            %Akexp = Ak(subs(nzctr1:nzctr,k),rctr1:rctr);
                            Akexp = Ak(subs(:,k),rctr1:rctr);
                            %size(Akexp,1)
                            %size(Akexp,2)
                            Vexp = Vexp .* Akexp;
                        end
                        for j = rctr1:rctr
                            vj = accumarray(subs(:,n), Vexp(:,j-rctr1+1), [nn 1]);
                            V(:,j) = V(:,j) + vj;
                        end
                        startBucket = stopBucket;
                        startRow = stopRow;
                        % ----
                    end
                end

            elseif ver == 2 % 'CHUNKED' SWAPPING R & NZ CHUNKS

                nz = nnz(X);
                d = ndims(X);
                nn = size(X,n);

                V = zeros(nn,R);
                nzctr = 0;
                while (nzctr < nz)

                    % Process nonzero range from nzctr1 to nzctr
                    nzctr1 = nzctr+1;
                    nzctr = min(nz,nzctr1+nzchunk);

                    rctr = 0;
                    Xvals = X.vals(nzctr1:nzctr);
                    while (rctr < R)

                        % Process r range from rctr1 to rctr (columns of factor matrices)
                        rctr1 = rctr + 1;
                        rctr = min(R, rctr + rchunk);
                        rlen = rctr - rctr1 + 1;

                        % ----
                        Vexp = repmat(Xvals,1,rlen);
                        for k = [1:n-1, n+1:d]
                            Ak = U{k};
                            Akexp = Ak(X.subs(nzctr1:nzctr,k),rctr1:rctr);
                            Vexp = Vexp .* Akexp;
                        end
                        for j = rctr1:rctr
                            vj = accumarray(X.subs(nzctr1:nzctr,n), Vexp(:,j-rctr1+1), [nn 1]);
                            V(:,j) = V(:,j) + vj;
                        end
                        % ----

                    end
                end
            end
        end

        function [subs,vals,bi,li] = retrieve(t, n, startBucket, startRow)
            % Retrieve n nonzeroes from the table, beginning at start,
            % which is a tuple containing [bucketIdx, rowIdx]. If an
            % element is present at start, then it is included in the
            % accumulation array.
            %
            % Returns:
            %   subs - A cell array of subscripts containing n nonzeros
            %   vals - An array of values corresponding to the subscripts
            %   bi - bucket index of the next nnz element
            %   li - row index of the next element past the most
            %        recently counted
            %
            subs = zeros(n,t.nmodes);
            vals = zeros(n,1);

            bi = startBucket;
            li = startRow;
            nctr = 0;

            %Accumulate nonzero indexes and values until we reach n
            while bi < t.nbuckets
                if isempty(t.table{bi})
                    bi = bi+1;
                    continue
                else
                    for li=li:size(t.table{bi}{1},1)
                        subs(nctr+1,:) = t.table{bi}{1}(li,:);
                        vals(nctr+1) = t.table{bi}{2}(li);
                        %vals(nctr+1) = t.table{bi}{li,2};
                        nctr = nctr+1;
                        if nctr == n
                            if li == size(t.table{bi}{1},1) %if no more in the chain, increment bucket index and reset list index
                                bi = bi+1;
                                li = 1;
                               fprintf("setting bucket index to next one/resetting list row index\n");
                            end
                            %Remove any remaining rows of 0s if we run out of nnz to get.
                            subs = subs(1:nctr,:);
                            vals = vals(1:nctr);
                            fprintf("got enough nonzeros, return...\n");
                            return
                        end
                    end
                end
                li = 1;
                bi = bi+1;
            end       
        end

        % Function to print all nonzero elements stored in the tensor.
        function display_htns(t)
            print_limit = 100;
            if (t.hash_curr_size > print_limit)
                prompt = "The sparse tensor you are about to print contains more than 100 elements. Do you want to print? (Y/N)";
                p = input(prompt,"s");
                if p == "Y" || p == "y"

                    fprintf("Printing tensor nonzeros.\n");
                    fmt=[repmat(' %d ',1,t.nmodes)];
                    %fmt=strcat(fmt," %d\n")

                    for i = 1:t.nbuckets
                        %skip empty buckets
                        if isempty(t.table{i})
                            continue
                        else
                            %disp(t.table{i})
                            for j = 1:size(t.table{i},1)
                                fprintf(fmt,t.table{i}{1}(j,:)); %print the index
                                fprintf(" %d\n",t.table{i}{2}(j)); %print the value
                            end
                        end
                    end
                end
            end
        end

        % Clear all entries and start with a new hash table.
        function t = clear(t, nbuckets)
            t = t.hash_init(t,nbuckets);
        end


    end %end of methods
end %end class