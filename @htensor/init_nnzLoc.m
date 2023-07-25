function t = init_nnzLoc(t)
%get the locations of nonempty cells
t.nnzLoc = find(~cellfun(@isempty,t.table));
end
