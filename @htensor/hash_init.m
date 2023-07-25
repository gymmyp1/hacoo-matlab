% Initialize all hash table related things
function t = hash_init(t,n)
t.nbuckets = n;
t.max_chain_depth = 0;
% create column vector w/ appropriate number of bucket slots
t.table = cell(t.nbuckets,1);

t = set_hashing_params(t);
end
