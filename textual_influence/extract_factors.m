function [V, F] = extract_factors (C, nfactors)
%{
 Extract factors (Algorithm 5).
Part of Lowe's Textual Influence model.
% Script to extract factors from all document tensors in the current directory.
% Input:
%   C - list of document tensors
%   nfactors - number of factors to use for decomposition
% Output:
%   F - list of factors
%   V - List of norms
%}


F = {}; %list of factors
V = {}; %list of norms

nmodes = size(C{1}.size,2);

for f=1:length(C)
    U = cp_nmu(C{f},nfactors); %non-negative CP for each document in list

    %reassemble the factors into tensors
    for i=1:nfactors
        T = U{1}(:,i);

        for m=2:nmodes
            %outer product, T times U{m}[:,i] in mode m
            T = tensorprod(T, U{m}(:,i),m); %multiply the column
        end

        %compute the norm and normalize the factor
        %lambda = L1_norm(T);

        lambda = normalize(T,"norm",1); %normalize by 1-norm (sum(abs(x))

        %normalizes the columns of the factors and arranges the rank-one pieces
        %in decreasing order of size.
        %T = arrange(U);

        T = T./lambda; %RDIVIDE for elementwise right divide

        %insert the factor and norm in the list
        F{end+1} = T;
        V{end+1} = lambda;
    end
end

