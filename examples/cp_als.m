%{ 
    Compute CP-ALS.
%}

tic
%create the HaCOO tensor
T = read_htns("uber.txt")
toc

%specify number of components
R = 50;

tic
%Computes an estimate of the best rank-R CP model of a tensor X (requires Tensor Toolbox)
V = htns_cp_als(T,R);
toc