function res = getslice(t, slice)

    resModes = cell(t.nmodes,1);
   
    %clean up the string
    slice = strsplit(slice,',');
    slice = erase(slice,'['); %<-- erase the brackets
    slice = erase(slice,']');

    %check if slice is correct size
    if t.nmodes == length(slice)
        for i = 1:length(slice)
            %if it's a colon, create a create a list of valid ranges
            if ismember(':',slice{i})
                %fprintf("make it a range\n");
                %for each mode make a range
                resModes{i} = 1:t.modes(i);
            else
                %fprintf("fixed index, just copy over\n");
                %else just copy over the fixed index
                resModes{i} = str2num(slice{i});
            end
        end
    else
        fprinf("invalid slice.\n");
        return
    end

    new_modes = [];
    %get maxes for the valid ranges
    for i = 1:length(slice)
        new_modes(i) = max(resModes{i});
    end
    
    % Create a new result tensor
    res = htensor(new_modes);
    
    %for each nnz, check if index is in the slice
    for i = 1:t.nbuckets
        %skip empty buckets
        if isempty(t.table{i})
            continue
        else
            %loop over every entry in the bucket
            for j = 1:length(t.table{i})
                %if we find a valid index in the slice, copy it to the tensor
                if in_slice(t.table{i}{j}.idx_id,resModes) == 0
                    %fprintf("subscript not in slice\n");
                    continue
                else
                    %fprintf("can copy this index over...\n");
                    %t.table{i}{j}.idx_id
                    res = res.set(t.table{i}{j}.idx_id, t.table{i}{j}.value);
                end
            end
        end
    end



    % Helper function to determine if an index is valid within a slice.
    % Parameters:
    %       i - index that we want to determine if it's in a slice
    %       slice - a cell array of valid ranges in desired slice
    % Returns:
    %       r - 1 if the index is within the slice, 0 if not.
    %
    function copy = in_slice(idx, slice)
        copy = 1; %<-- copy flag
        %check if whole subscript is in the slice
        for k = 1:length(slice)
            if ismember(idx(k),slice{k})
                continue
            else
                copy = 0; %<-- don't copy this 
                %fprintf("invalid subscript\n");
                return
            end
        end
        %fprintf("valid subscript\n");
    end

end


