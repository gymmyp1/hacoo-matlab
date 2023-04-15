%Read tset for testing writing a HaCOO tensor to COO format.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

t = read_htns('y.txt');
%t = read_htns('uber_trim.txt')
%t = read_htns('uber.txt')

t.display_htns()

write_coo(t,'y_coo.txt')

