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

if concatIdx ~= -1
    %if a concatenated index got passed, search using that
    [k, i] = search(idx,'concatIdx',concatIdx);
else
    % try to find the index
    [k, i] = search(idx);
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
    t = rehash();
end
end

