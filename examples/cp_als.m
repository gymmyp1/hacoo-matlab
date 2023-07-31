%{ 
    Compute CP-ALS.
%}

file = "uber.txt";

%create the HaCOO tensor
X = read_htns(file)

%specify number of components
R = 50;

%Computes an estimate of the best rank-R CP model of a tensor X (requires Tensor Toolbox)
V = htns_cp_als(X,R);