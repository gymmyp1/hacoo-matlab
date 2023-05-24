%Driver code for testing cp_als function.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

%file = 'uber_hacoo.mat';
file = 'uber_hacoo.mat';
fprintf("Loading HaCOO .mat file.\n");
T = load_htns(file);
fprintf("Finished loading.\n");

M = htns_cp_als(T,50);

toc

%make tensor toolbox sptensor
table = readtable(file);
arr = table2array(table);

idx = arr(:,1:end-1);
vals = arr(:,end);

%{
tic
%create tensor toolbox sptensor
X = sptensor(idx,vals);
tt_res = cp_als(X,50); %compare to TT's results

toc
%}

