%Driver code for testing cp_als function.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

t = read_tns('test.txt');

M = cp_als(t,50);