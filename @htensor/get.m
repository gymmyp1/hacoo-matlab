%{
		Retrieve a tensor value.
		Parameters:
			t - The tensor
            i - The tensor index to retrieve
		Returns:
            item - the value at index i if found, 0.0 if not found 
%}
function item = get(t, i)

[k,j] = search(t,i);

if j ~= -1
    item = t.table{k}(end); %return the index's value
    return
else
    %item is not found
    item = 0;
    return
end
end