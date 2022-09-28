% Read a text file into a HaCOO sparse tensor
% 
% Input:
%       file - text file string
% Returns:
%       t - HaCOO htensor containing nnz from the file
%
% Expects text file input of the format: 
%       idx_1, idx_2,...idx_n val

function t = read_tns(file)
    table = readtable(file);
    arr = table2array(table);
    
    idx = arr(:,1:end-1);
    vals = arr(:,end);
    
    t = htensor(idx,vals);
end