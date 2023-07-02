%Driver code for testing all_subs() and all_vals()

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
%t = read_htns('uber.txt');

%t.all_subs
%t.all_vals
tic
[subs,vals] = t.all_subsVals;
toc
