%Read test for testing htensor(HaCOO) class

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
t = read_htns('x.txt')
%t = read_htns('uber_trim.txt')
%t = read_htns('uber.txt')
%t = read_htns('chicago-crime-comm.txt')

t.display_htns();
toc
