%{ 
    Compute CP-ALS.
%}

%create the HaCOO tensor
T = read_htns("uber.txt") %tensor can be downloaded from the FROSTT repository

%specify number of components
R = 50;

%Compute an estimate of the best rank-R CP model of a tensor X (requires Tensor Toolbox)
V = htns_cp_als(T,R);