%Driver code for testing htensor(HaCOO) class
%working 9/20

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
%file = 'uber.txt';
file = 'test2.txt';

table = readtable(file);

idx = table(:,1:end-1);
vals = table(:,end);

idx = table2array(idx);
vals = table2array(vals);

t = htensor(idx,vals)

%t.get([2,3,5])
%t.get([1,4,4])

%t.display_tns();
toc