addpath /Users/meilicharles/Documents/MATLAB/tensor_toolbox-v3.2.1

%U = {rand(2,3), 2*rand(3,3), 3*rand(4,3)}; %<--the cell array

modes = 3;

a = [1 3 5; 2 4 6];
b = [1 4 7; 2 5 8; 3 6 9];
c = [1 2 3; 4 5 6; 7 8 9; 10 11 12];
U = cell(1,modes);
U{1} = a;
U{2} = b;
U{3} = c;

subs = [1,1,1;
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
X = sptensor(subs,vals); %<--the tensor

n = 2; %<--the dimension to matricize with respect to.

%KRP = khatrirao(U{2}, U{3}); %<--Khatri-Rao product, omitting U{n}
%M = permute(X.data, [n:size(X,n), 1:n-1]);
%M = reshape(M,size(X,n),[]); %<--Matricized tensor data

mttkrp(X,U,1) %<--matricize with respect to dime nsion 1.
mttkrp(X,U,2)
mttkrp(X,U,3)

%norm(M*KRP-mttkrp(X,U,n)) < 1e-14 %<--They are equal, within machine precision
