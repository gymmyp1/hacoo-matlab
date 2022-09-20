% Determine if an index is valid within a slice.
% Parameters:
%       i - index that we want to determine if it's in a slice
%       slice - a cell array of valid ranges in desired slice
% Returns:
%       r - 1 if the index is within the slice, 0 if not.
%
function copy = in_slice(idx, slice)
    copy = 1; %<-- copy flag
    %check if whole subscript is in the slice
    for i = 1:length(slice)
        if ismember(idx(i),slice{i})
            continue
        else
            copy = 0; %<-- don't copy this 
            %fprintf("invalid subscript\n");
            return
        end
    end

    %fprintf("valid subscript\n");
end