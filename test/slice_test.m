% Function testing for retrieving tensor slices.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

modes = [2,3,5];
slice = {1:2;1:3;5}
s = getslice(slice, modes)