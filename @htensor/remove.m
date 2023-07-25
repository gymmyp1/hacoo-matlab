% Remove an existing tensor entry.
% Parameters:
%       t - A HaCOO htensor
%       i - the index entry to remove
% Returns:
%       t - the updated tensor
%
function t = remove(t,i)

[k,j] = search(t,i);

if j ~= -1 %<-- we located the index successfully
    t.table{k}(j,:) = []; %delete the entire row
    t.hash_curr_size = t.hash_curr_size-1;

    %if that was the only entry in that bucket, remove that key
    %from the occupied bucket list
    if size(t.table{k},1) == 0
        t.nnzLoc = t.nnzLoc(t.nnzLoc~=k);
    end
else
    fprintf("Could not remove nonzero entry.\n");
    return
end
end