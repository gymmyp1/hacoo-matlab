% Clear all entries and start with a new hash table.
function t = clear(t, nbuckets)
t = hash_init(t,nbuckets);
end