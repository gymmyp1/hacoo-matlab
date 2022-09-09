%Driver code for testing HaCOO class
%working on this 9/9
%Goal: figure out vecotrized way to concatenate all indexes 
% across columns
%table version

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
%file = 'uber.txt';
file = 'test.txt';
T1 = readtable(file);

idx = T1(:,1:end-1);
vals = T1(:,end);

idx = convertvars(idx, idx.Properties.VariableNames, 'string');

%Trying to figure out a way to concatenate indexes over each row...
%concat_idx = rowfun(@cc, idx, 'SeparateInputs', false);
concat_idx = rowfun(@strcat, idx, 'SeparateInputs', false);
concat_idx = rowfun(@join, concat_idx);
concat_idx = rowfun(@rmspaces, concat_idx);
concat_idx = rowfun(@str2num, concat_idx);

%concat_idx = table2array(concat_idx)
toc

function res = rmspaces(idx)
    res = strrep(idx,' ',''); %<-- remove spaces
end

function res = cc(idx)
    res = join(strcat(idx)); %<-- concatenate across columns
    res = strrep(res,' ',''); %<-- remove spaces
    %res = str2num(res); %<-- convert to int 
    %res = uint16(res);
end


