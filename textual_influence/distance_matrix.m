%{
  Measure the similarity by finding L_1 distance between each pair of 
  factors (Algorithm 6).
  Result is a matrix M where M_ij is the L_1 distance b/w F_i and F_j.
  0 is a perfect match & 2 is maximum distance.

Input:
    F - list of factors
Output:
    M - matrix with dimention |F| x |F| with distances between every 
        pair of factors
%}
function M = distance_matrix (F)

nfactors = length(F);

%classify each document factor as either belonging to the set F_t^s (target
%factors w/ sources) or F_t^n (target factors without sources).
M = zeros(nfactors,nfactors); %distance matrix

%i is the index of a target factor and j is the index of a potential source
%factor.

for i=1:nfactors
    for j=1:nfactors
        M(i,j) = normalize(F{i}-F{j},"norm",1);
    end
end

end