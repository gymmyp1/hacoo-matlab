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
