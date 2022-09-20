% Function testing for retrieving tensor slices.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

file = 'test2.txt';
table = readtable(file);
idx = table(:,1:end-1);
vals = table(:,end);
idx = table2array(idx);
vals = table2array(vals);

t = htensor(idx,vals);

slice = '[:,:,5]'; %<-- for now this needs to be a string o.w. matlab fusses
r = getslice(t,slice)

r.display_tns()