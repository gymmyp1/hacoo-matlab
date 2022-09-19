function res = getslice(t, slice, modes)

    %Create result tensor
    res = hacoo();

    %copy relevant non-zeros
    for i = 1:t.nbuckets
        
        %skip if no entries
        if isempty(t.table{k})
                continue
        end

        %for every bucket in the chain
        for j = 1:length(t.table{i})
            %Copy the things in our range
            copy = 1;
            idx = t.table{i}{j}.idx_id;
            if(isequal(v1,v2)) %<-- not sure if this is right..
                res = res.set(idx, t.table{i}{j}.value);

        end
    end
end


