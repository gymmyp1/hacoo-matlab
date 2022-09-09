%Driver code for testing HaCOO class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
%file = 'uber.txt';
file = 'test.txt';

table = readtable(file);

idx = table(:,1:end-1);
vals = table(:,end);

modes = [5,5,5];

t = hacoo(idx,vals,modes);
toc


%ubermodes = [183;24;1140;1717];