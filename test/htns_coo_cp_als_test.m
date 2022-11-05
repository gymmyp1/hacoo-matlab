%Driver code for testing cp_als function using "chunked" COO approach.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

file = 'uber_hacoo.mat';
fprintf("Loading HaCOO .mat file.\n");
T = load_htns(file);
fprintf("Finished loading.\n");

M = htns_coo_cp_als(T,15);

toc
