%Driver code for testing new htensor(HaCOO) class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
t = read_htns('x.txt');
%t = new_read_htns('uber_trim.txt');
t.save_htns();
%t.all_indexes()
%t.all_vals()

%t.display_htns();

toc