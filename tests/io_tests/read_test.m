%Convert a COO .txt file to an htensor/HaCOO tensor

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

t = read_htns('uber.txt')

display_htns(t);
toc
