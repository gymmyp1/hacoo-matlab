%Driver code for testing embedding a linked list in a cell array

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

%{
hash_item = struct('morton',23897,'value',2,'next',NaN,'last',NaN);
hash_item.last = hash_item %<-- set last item as itself?
hash_item.last
table = cell(10,1)
table{1} = hash_item
table{1}
table{1}.next = struct('morton',123,'value',1,'next',NaN);
table{1}
%}

nbuckets = 512;
i = 1;
table = cell(nbuckets,1); %<-- create the cell table of structs
for i = 1:t.nbuckets
    table{i} = struct('morton',0,'value',0,'next',0);
end

k = 1;
m = 2894;
if table{k}.morton ~= 0 %<-- check if that whole slot is not empty
    i = 1;
    item = table{k};
    item
    while item.next ~= 0 %<-- check if there's a next element in chain
        if item.morton == m
            return
        end
        item = item.next; %<-- increment thru the chain
        i = i+1;
    end
    i = -1; %<-- item was not found
    return;
end