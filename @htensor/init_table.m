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
    %fprintf('idx: ')
    %idx(i,:)
    hash = concatIdx(i);
    hash = hash + bitshift(hash,t.sx);
    %fprintf("after left shift: %d\n",hash)
    hash = bitxor(hash, bitshift(hash,-t.sy));
    %fprintf("after right shift: %d\n",hash)
    hash = hash + bitshift(hash,t.sz);
    %fprintf("after left shift: %d\n",hash)
    keys(i) = mod(hash,t.nbuckets);
    %fprintf("k: %d\n",keys(i))
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