%Driver code for testing htensor(HaCOO) class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
t = read_tns('x.txt');

%t.get([2,3,5])
%t.get([1,4,4])

%t.display_tns();
t.get_indexes()
toc