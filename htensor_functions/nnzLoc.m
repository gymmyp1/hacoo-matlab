%Return the indexes of nonzempty hash table buckets.

function r = nnzLoc(t)
    r = find(~cellfun(@isempty,t.table));
end