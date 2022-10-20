% Read a text file into a HaCOO sparse tensor
% 
% Input:
%       file - text file string
% Returns:
%       t - HaCOO htensor containing nnz from the file
%
% Expects text file input of the format: 
%       idx_1, idx_2,...idx_n val

function t = read_htns(file)
    table = readtable(file);
    
    idx = table{:,1:end-1};
    vals = table{:,end};
    
    t = htensor(idx,vals);
end