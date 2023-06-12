%Driver code for testing htensor(HaCOO) class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
t = read_htns('x.txt')

t.display_htns();

t = t.set([2 4 1], 2)
t = t.set([5 4 5], 5)

t.display_htns()

%t = t.remove([1 1 1]);
%t = t.remove([2 1 1]);
%t = t.remove([1 2 1]);

%t.display_htns()

toc