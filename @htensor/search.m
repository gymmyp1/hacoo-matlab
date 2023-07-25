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
    k = hash(t,concatIdx);
else
    %concatenate the index
    s = num2str(idx);
    s = strrep(s,' ','');
    s = str2double(s);
    k = hash(t,s);
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