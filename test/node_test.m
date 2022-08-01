%Driver code for testing node class

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

nbuckets = 10;
table = cell(nbuckets,1); %<-- create the cell table

for i = 1:nbuckets
    table{i} = cell(1);
end

table{1}{1} = node(14,1);
table{1}{2} = node(512,2);
%table{1}
length(table{1})

for i = 1:length(table{1})
    table{1}{i}
end
