%{
 Part of Lowe's Textual Influence model.
% Script to extract factors from all document tensors in the current directory.
% Input:
%   nfactors - number of factors to use for decomposition
% Output:
%   F - list of factors
%   V - List of norms
%}

F = {};
V = {};

%create sptensor from file
X = read_coo("lin_sax_coo.txt");
nmodes = size(X.size,2);

%calculate how many factors we need using Eq. 2.5
nnz = length(X.vals);
r = nthroot(nnz, 3); %cube root
nfactors = ceil(nnz/(3 * r -2));
fprintf("number of factors: %d\n",nfactors);

U = cp_als(X,nfactors); %need to figure out how many factors to decompose

%reassemble the factors into a tensor
for i=1:nfactors
    %build the factor
    T = U.U{1}(:,i);
    for m=2:nmodes
        T= T.* U.U{m}(:,i);    %T <- T \ocross U[m][:,i]
    end

    %compute the norm and normalize the factor
    lambda = norm(T);
    T = T/lambda;

    %insert the factor and norm in the list
    F{end+1} = T;
    V{end+1} = lambda;

end

