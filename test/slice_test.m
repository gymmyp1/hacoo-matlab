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

r1 = getslice(t,'[:,:,5]');
r2 = getslice(t,'[:,1,:]');

%r.display_tns();
r2.display_tns()