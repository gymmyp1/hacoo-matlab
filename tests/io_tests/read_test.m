%Read test for testing htensor(HaCOO) class

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

t = read_htns('coo_ex.txt')

t.display_htns();
toc
