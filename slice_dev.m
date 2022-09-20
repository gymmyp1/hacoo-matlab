%developing get_slice function

file = 'test2.txt';
table = readtable(file);
idx = table(:,1:end-1);
vals = table(:,end);
idx = table2array(idx);
vals = table2array(vals);

t = htensor(idx,vals);



resModes = cell(t.nmodes,1);

%this should be a valid index for test2 tensor
slice = '[:,:,5]'; %<-- for now this needs to be a string o.w. matlab fusses

%clean up the string
slice = strsplit(slice,',');
slice = erase(slice,'['); %<-- erase the brackets
slice = erase(slice,']');



%check if slice is correct size
if t.nmodes == length(slice)
    for i = 1:length(slice)
        %if it's a colon, create a create a list of valid ranges
        if ismember(':',slice{i})
            for i = 1:t.nmodes
                %for each mode make a range
                resModes{i} = 1:t.modes(i);
            end
        else
            %else just copy over the fixed index
            resModes{i} = str2double(slice{i});
        end
    end
else
    fprinf("invalid slice.\n");
end

resModes

new_modes = [];
%get maxes for the valid ranges
for i = 1:length(slice)
    new_modes(i) = max(resModes{i});
end

% Create a new result tensor
res = htensor(new_modes);

%just testing a dummy entry
idx = [1,2,5]; %this should be in the slice
bad_idx = [1,2,3]; %this should NOT be in the slice


%for each nnz, check if index is in the slice

for i = 1:t.nbuckets
    %skip empty buckets
    if isempty(t.table{i})
        continue
    else
        %loop over every entry in the bucket
        for j = 1:length(t.table{i})

            %if we find a valid index in the slice, copy it to the tensor
            if in_slice(t.table{i}{j}.idx_id,resModes)
                fprintf("can copy this index over...\n");
                res = res.set(t.table{i}{j}.idx_id, t.table{i}{j}.value)
            end
        end
    end
end

res.display_tns()

%{
%just testing
if ismember(0,resModes{1})
        fprintf('valid sub in range\n')
    else
        fprintf('invalid sub in range\n')
    end
%}