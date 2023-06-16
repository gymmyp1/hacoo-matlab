%file to test htns_extract function

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

file = 'x.txt';
%file = 'uber_trim.txt';
T = read_htns(file);

%subset of indexes to extract
subs = [1 1 1; 1 3 1];

M = htns_extract(T,subs);
disp(M);