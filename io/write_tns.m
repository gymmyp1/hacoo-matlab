% Write a HaCOO sparse tensor to a file.
% 
% Input:
%       t - a HaCOO htensor
%       file - text file string to write to
% Returns:
%       t - HaCOO htensor containing nnz from the file
%
% Writes to text file in the format: 
%       idx_1, idx_2,...idx_n val

function write_tns(t, file)
    fprintf("Writing tensor to file...\n");
    fileID = fopen(file,'w');
    
    for i = 1:t.nbuckets
        if isempty(t.table{i})
            continue
        else
            for j = 1:length(t.table{i})
                fprintf(fileID,'%d %f %d\n',t.table{i}{j}.morton,t.table{i}{j}.value,i);
            end
        end
    end

    fclose(fileID);
end