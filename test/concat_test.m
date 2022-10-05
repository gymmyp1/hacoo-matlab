%This is an old file, concatenation has been replaced by summing
%the index for hashing b/c this was too slow.

%Driver code for testing HaCOO class
%Goal: figure out vecotrized way to concatenate all indexes 
% across columns

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
%file = 'uber.txt';
file = 'test.txt';
T1 = readtable(file);

idx = T1(:,1:end-1)
vals = T1(:,end)

idx = convertvars(idx, idx.Properties.VariableNames, 'string');
idx = table2array(idx)

concat_idx = arrayfun(@cc,idx, 'SeparateInputs', false)

%Trying to figure out a way to concatenate indexes over each row...
%concat_idx = rowfun(@cc, idx, 'SeparateInputs', false)
toc

function res = cc(idx)
    res = join(strcat(idx)); %<-- concatenate across columns
    res = strrep(res,' ',''); %<-- remove spaces
    res = str2num(res); %<-- convert to int 
    res = uint16(res);
end


