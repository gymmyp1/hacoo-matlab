%Driver code for testing node class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

nbuckets = 10;
table = cell(nbuckets,1); %<-- create the cell table

for i = 1:nbuckets
    table{i} = cell(1);
end

if isempty(table{1})
    fprintf("empty cell\n")
else
    fprintf("not empty\n")
end

table{1}{1} = node();
table{1}{2} = node(512,2);
table{1}{3} = node(5,5);
table{1}

length(table{1})

table{1}

for i = 1:length(table{1})
    if table{1}{i}.morton == -1
        continue
    end
   
        table{1}{i}
    
end

function t = remove(t,m)
%need to find the element to remove, then slide back all data after that
% and resize the cell array
    
end