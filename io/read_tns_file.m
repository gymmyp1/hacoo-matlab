%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

%Read a tns file and separate indexes and values into separate matrices.

[idx,vals] = read_tns('test.txt');
t = hacoo(idx,vals,[5 5 5]);

function [idx,vals] = read_tns(file)
    table = readtable(file);
    table = table2array(table);
    
    idx = table(:,1:end-1);
    vals = table(:,end);
end