%Driver code for testing cp_als function.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

%file = 'x.txt';
file = 'uber_trim.txt';
%T = read_htns(file);

%M = htns_cp_als(T,50);


%make tensor toolbox sptensor
table = readtable(file);
arr = table2array(table);

idx = arr(:,1:end-1);
vals = arr(:,end);

%create tensor toolbox sptensor
X = sptensor(idx,vals);
tt_res = cp_als(X,50); %compare to TT's results

