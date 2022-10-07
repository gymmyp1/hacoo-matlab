%Test for htns_innerprod function.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

file = 'x.txt';
T = read_htns(file);

%set up Tensor Toolbox sptensor
table = readtable(file);
idx = table(:,1:end-1);
vals = table(:,end);
idx = table2array(idx);
vals = table2array(vals);

X = sptensor(idx,vals);

%set up tensor Y

%tensor toolbox's version
%a2 = innerprod(X,X)

%my version
a1 = htns_innerprod(T,X)