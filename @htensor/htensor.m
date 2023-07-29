%{
% HACOO class for sparse tensor storage.
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
function t = htensor(varargin)

t.hash_curr_size = 0;
t.load_factor = 0.6;

%EMPTY constructor
if (nargin == 0)
    t.size = [];   %<-- EMPTY class constructor
    NBUCKETS = 512;
    t = hash_init(t,NBUCKETS);
    t.nnzLoc = find(~cellfun(@isempty,t.table));
    t = class(t,'htensor');
    return

end

%SINGLE ARGUMENT
if (nargin == 1)
    %source = varargin{1};

    if isscalar(varargin{1})
        t.size = [];
        t = hash_init(t,varargin{1});
        t.nnzLoc = find(~cellfun(@isempty,t.table));
        t = class(t,'htensor');
        return
    elseif isstring(varargin{1})
        %load from .mat file
        loaded = matfile(varargin{1});
        t = loaded.t; %load table
        t = class(t,'htensor');
        return
    end
end


if (nargin == 2) %Subs and vals specified as arg1 and arg2
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

    t.size = max(idx);
    nnz = size(idx,1);
    reqSize= power(2,ceil(log2(nnz/t.load_factor)));
    NBUCKETS = max(reqSize,512);

    % Initialize all hash table related things
    t = hash_init(t,NBUCKETS);
    t = init_table(t,idx,vals,concatIdx);
    t.nnzLoc = find(~cellfun(@isempty,t.table));
    t = class(t,'htensor');
    return
end
if (nargin == 3)
    idx = varargin{1};
    vals = varargin{2};
    concatIdx = varargin{3};

    t.size = max(idx);
    nnz = size(idx,1);
    reqSize= power(2,ceil(log2(nnz/t.load_factor)));
    NBUCKETS = max(reqSize,512);

    % Initialize all hash table related things
    t = hash_init(t,NBUCKETS);
    t = init_table(t,idx,vals,concatIdx);
    t.nnzLoc = find(~cellfun(@isempty,t.table));
    t = class(t,'htensor');
    return
end

%Nested init functions
    % Initialize all hash table related things
    function t = hash_init(t,n)
        t.nbuckets = n;
        t.max_chain_depth = 0;
        % create column vector w/ appropriate number of bucket slots
        t.table = cell(t.nbuckets,1);
        t = set_hashing_params(t);
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
    Initialize a list of subscripts and values in the sparse tensor hash table.
    Parameters:
	    idx - Array of nonzero subscripts
        vals - Array of nonzero tensor values
        concatIdx - Array of nonzero subscripts that have been concatenated.
    Returns:
	    A hacoo data type with a populated hash table.
    %}
    function t = init_table(t,idx,vals,concatIdx)

        keys = zeros(length(idx),1);

        for j = 1:length(idx)
            hash = concatIdx(j);
            hash = hash + bitshift(hash,t.sx);
            hash = bitxor(hash, bitshift(hash,-t.sy));
            hash = hash + bitshift(hash,t.sz);
            keys(j) = mod(hash,t.nbuckets);
        end

        keys(keys == 0) = 1;

        for j=1:length(keys)
            %check if the slot is occupied already
            if isempty(t.table{keys(j)})
                %if not occupied already, just insert
                t.table{keys(j)} = [idx(j,:) vals(j)];
            else
                t.table{keys(j)} = vertcat(t.table{keys(j)},[idx(j,:) vals(j)]);
            end
            depth = size(t.table{keys(j)},1);
            if depth > t.max_chain_depth
                t.max_chain_depth = depth;
            end
            t.hash_curr_size = t.hash_curr_size + 1;
        end
    end

end