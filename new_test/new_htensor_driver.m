%Driver code for testing new htensor(HaCOO) class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
t = read_htns('x.txt');
%t = read_htns('uber_trim.txt');

%t.display_htns();
%[key, j] = t.search([1 1 1])
%t.get([1 1 1])
%t.get([6 3 2])
t.save_htns('x.mat');
%t.all_indexes()
%t.all_vals()



toc