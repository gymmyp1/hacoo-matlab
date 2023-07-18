t = read_htns('coo_ex.txt');

%-----------
tic
%get the locations of nonempty cells
nnzLoc = find(~cellfun(@isempty,t.table));

%extract only nonempty cells
t.table(nnzLoc);
toc
%-----------

tic
%use find to iterate over nonempty cells
for i=1:size(nnzLoc,1)
    disp(t.table{i})
end
toc

tic
%use usual way
t.display_htns;
toc