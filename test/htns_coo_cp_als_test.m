%Driver code for testing cp_als function using "chunked" COO MTTKRP.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

%file = 'y.txt';
%T = read_htns(file); %<--HaCOO htensor


file = 'ubertrim_hacoo.mat';
fprintf("Loading HaCOO .mat file.\n");
T = load_htns(file);
fprintf("Finished loading.\n");


M = htns_coo_cp_als(T,15);

toc
