%Testing write function for HaCOO .mat files

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

fprintf("Saving tensor to file...\n");
%t = read_htns('uber_trim.txt');
t = read_htns('uber.txt');

%matfile = "ubertrim_hacoo.mat";
matfile = "uber_hacoo.mat";
write_htns(t,matfile);

toc