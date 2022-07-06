%Driver code for testing embedding a linked list in a cell array

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

hash_item = struct('morton',123,'value',1,'next',-1,'last',-1);
hash_item.last = hash_item %<-- set last item as itself?
hash_item.last
new_item = struct('morton',-1,'value',-1,'next',-1,'last',-1);
hash_item.next = new_item
hash_item.last = new_item;
table = cell(10,1)
table{1} = hash_item
table{1}.last
