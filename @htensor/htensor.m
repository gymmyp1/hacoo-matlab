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

%specifying this ahead of time... hash init repeats some of this :(
t.table = [];
t.nbuckets = [];
t.modes = [];
t.nmodes = [];
t.bits = [];
t.sx = [];
t.sy = [];
t.sz = [];
t.mask = [];
t.max_chain_depth = [];
t.hash_curr_size = [];
t.nnzLoc = [];

%EMPTY constructor
if (nargin == 0)
    t.modes = [];   %<-- EMPTY class constructor
    t.nmodes = 0;
    NBUCKETS = 512;
    t = hash_init(t,NBUCKETS);
    t = init_nnzLoc(t);
    t = class(t,'htensor');
    return

end

%SINGLE ARGUMENT
if (nargin == 1)
    %source = varargin{1};

    if isscalar(varargin{1})
        t.modes = [];
        t.nmodes = 0;
        t = hash_init(t,varargin{1});
        t = init_nnzLoc(t);
        t = class(t,'htensor');
        return
    elseif isstring(varargin{1})
        %load from .mat file
        loaded = matfile(varargin{1});
        t.table = loaded.t; %load table
        %t = class(t,'htensor');
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

    t.modes = max(idx); %<-- if input is an array
    t.size = t.modes; %new
    t.nmodes = length(t.modes);

    nnz = size(idx,1);
    reqSize= power(2,ceil(log2(nnz/t.load_factor)));
    NBUCKETS = max(reqSize,512);

    % Initialize all hash table related things
    t = hash_init(t,NBUCKETS);
    t = init_table(t,idx,vals,concatIdx);
    t = init_nnzLoc(t);
    t = class(t,'htensor');
    return
end
if (nargin == 3)
    idx = varargin{1};
    vals = varargin{2};
    concatIdx = varargin{3};

    t.modes = max(idx);
    t.nmodes = length(t.modes);

    nnz = size(idx,1);
    reqSize= power(2,ceil(log2(nnz/t.load_factor)));
    NBUCKETS = max(reqSize,512);
    %t = class(t,'htensor');
    % Initialize all hash table related things
    t = hash_init(t,NBUCKETS);
    t = init_table(t,idx,vals,concatIdx);
    t = init_nnzLoc(t);
    t = class(t,'htensor');
    return
end

end %<--end function