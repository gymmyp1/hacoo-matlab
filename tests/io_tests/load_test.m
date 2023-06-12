%Testing load function for HaCOO .mat files

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

file = "uber_hacoo.mat";
t = load_htns(file);

toc