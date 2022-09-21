%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

modes = 3;

a = [1 3 5; 2 4 6];
b = [1 4 7; 2 5 8; 3 6 9];
c = [1 2 3; 4 5 6; 7 8 9; 10 11 12];
U = cell(1,modes);
U{1} = a;
U{2} = b;
U{3} = c;

idx = [1,1,1;
        1,2,1;
        1,3,1;
        2,1,1;
        2,2,1;
        2,3,1;
        1,1,2;
        1,2,2;
        1,3,2;
        2,1,2;
        2,2,3;
        2,3,4];

vals = [1;2;3;4;5;6;7;8;9;10;11;12];
T = hacoo(idx,vals); %<--the tensor

mttkrp(T,U,1) %<--matricize with respect to dimension 1.
mttkrp(T,U,2)
mttkrp(T,U,3)

