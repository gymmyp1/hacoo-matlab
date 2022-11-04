%Testing write function for HaCOO .mat files

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
t = read_htns('uber_trim.txt');

file = "ubertrim_hacoo.mat";
write_htns(t,file);

toc