%{
Extract influence: each factor in the target document must be assisgned the
source factor w/ the minimum distance (w/in a reasonable threshold). 

Input:
    ndocs - number of documents in corpus
    M - distance matrix
    V - list of factor L1 norms
    threshold - threshold to classify factors (set to 0.2)

Output:
    W - list of weights
    S - set where entry S_i is the index of the factor which is the source
    or target factor i. If target factor i has no assignable source, then
    S_i gets a value of zero.
%}
function [W, S] = extract_influence(ndocs, M, V, threshold)

%Compute weights
s = sum(V);
W = V/s;
S = zeros(length(V)); %list of integers of size |V|

%Classify factors
nfactors = length(V);

%we only need to compare M[i,j] where i is index of target factor & j is
%index of a potential source factor.

for i=1:nfactors
    %row = i + nfactors * (ndocs-1); 
    row = i + nfactors * (ndocs); %not sure if the -1 needed to be removed
    min = M(row,1);
    minIndex = 1;
    

    for j=1:nfactors*ndocs
        if M(row,j) < min
            min = M(row,j);
            minIndex = j;
        end
    end

    if min <= threshold
        S(i) = minIndex;
    else
        S(i) = 0;
    end

end
