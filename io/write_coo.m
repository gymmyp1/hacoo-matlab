%{
  Write a HaCOO sparse tensor to a file in COO format.
  
% Input:
%       t - a HaCOO htensor
%       file - text file string to write to, file name must end in '.txt'
%}

function write_coo(t,file)
fileID = fopen(file,'w');

num_modes = t.nmodes;
fmt = repmat('%d ',1,num_modes);

for i = 1:t.nbuckets
    %skip empty buckets
    if isempty(t.table{i})
        continue
    else
        for j = 1:size(t.table{i}{1},1)
            fprintf(fileID, fmt, t.table{i}{1}(j,:)); %print the index
            fprintf(fileID,"%d\n",t.table{i}{2}(j)); %print the value
        end
    end
end

fclose(fileID);

end