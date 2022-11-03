%Testing write and load functions for HaCOO .mat files

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

t = read_htns('x.txt');

file = "x_hacoo.mat";
write_htns(t,file);
t = load_htns(file);

t.display_htns()