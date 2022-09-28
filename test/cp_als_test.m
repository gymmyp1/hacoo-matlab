%Driver code for testing cp_als function.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

file = 'x.txt';
file = 'uber_trim.txt';
t = read_tns(file);

M = scrap(t,50);
%M = cp_als(t,50);


%make tensor toolbox sptensor
table = readtable(file);
arr = table2array(table);

idx = arr(:,1:end-1);
vals = arr(:,end);

%create tensor toolbox sptensor
X = sptensor(idx,vals);
cp_als(X,50)
