%Driver code for testing HaCOO's cp_als function.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

%file = 'uber_hacoo.mat';
%fprintf("Loading HaCOO .mat file.\n");
%T = load_htns(file);
%fprintf("Finished loading.\n");

M = htns_cp_als(T,50);

toc