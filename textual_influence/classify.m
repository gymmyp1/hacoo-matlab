%{
 Part of Lowe's Textual Influence model.
% Script to extract factors from all document tensors in the current directory.
% Input:
%   nfactors - number of factors to use for decomposition
% Output:
%   F - list of factors
%   V - List of norms


Target paper: Serfas, Doug- Dynamic Biometric Recognition of Handwritten 
Digits Using Symbolic Aggregate Approximation (2017 ACM Proceedings Southeast Conference)
%}

docTns = {}; %list of document tensors
F = {}; %list of factors
V = {};

%nfactors = 150;
nfactors = 10;
threshold = 0.2;

%list of documents in corpus
%files = ["lin_sax_coo.txt" "serfas_dynamicbiometric_coo.txt"];
files = ["lin_sax_coo.txt" "schlapbach_hmm_coo.txt" "gazzah_arabic_coo.txt" "manabe_identity_coo.txt" "kolda_multilinear_coo.txt" "blei_latent_coo.txt" "serfas_dynamicbiometric_coo.txt"];

%for each document in the corpus create sptensor from file
for i=1:length(files)
    docTns{end+1} = read_coo(files(i));
end

nmodes = size(docTns{1}.size,2);

U = cp_nmu(docTns{1},nfactors); %non-negative CP

%T = tensor(U{1}(:,i));
%T = U{1}(:,i);
%size(T)
%T = tensorprod(T, U{2}(:,i),2);
%size(T)
%reassemble the factors into tensors
for i=1:nfactors
    T = U{1}(:,i);
    %T = ttv(T, {U{2}(:,i),U{3}(:,i)},[2 3])
    
    %build the factor
    %T = tensor(U{1}(:,i)); %start out the tensor w/ a vector
    
    for m=2:nmodes %ndims(Y) = ndims(X) - 1 because the N-th dimension is removed.
        %outer product, T times U{m}[:,i] in mode m
        %T = ttv(T,U{m}(:,i),m-1); %multiply the column
        T = tensorprod(T, U{m}(:,i),m);
    end

   %{
    T = tensor;
   iv = U{1}(:,i);
   jv = U{2}(:,i);
   kv = U{3}(:,i);
   %for each element in the column
   for ic=size(U{1}(:,i),1)
       for jc = 1:size(U{1}(:,i),1)
           for kc =1:size(U{1}(:,i),1)
                T([ic jc kc]) = iv(m) * jv(m) * kv(m);
           end
       end
   end

   size(T)
   %}

    %compute the norm and normalize the factor
    %lambda = L1_norm(T);
    %T = T/lambda;

    %normalizes using the vector one norm (sum(abs(x)) rather than the two 
    % norm (sqrt(sum(x.^2))), where V can be any of the second arguments 
    % decribed above.
    %T = normalize(U,U{i},1);

    %normalizes the columns of the factors and arranges the rank-one pieces
    %in decreasing order of size.
    %T = arrange(U);
    

    %insert the factor and norm in the list
    F{end+1} = T;
    %V{end+1} = lambda;

end

F

%classify each document factor as either belonging to the set F_t^s (target
%factors w/ sources) or F_t^n (target factors without sources).
M = zeros(nfactors,nfactors); %distance matrix

%i is the index of a target factor and j is the index of a potential source
%factor.

for i=1:nfactors
    for j=1:nfactors
        %M(i,j) = L_1_norm of F(i) - (F(j);
        %F{i}
        %F{j}
        norm(F{i}-F{j}); %calc the distance b/w two points as the norm of the difference b/w the vector elements
    end
end

%measure the similarity by finding L_1 distance between each pair of factors.
%Result is a matrix M where M_ij is the L_1 distance b/w F_i and F_j.
%0 is a perfect match & 2 is maximum distance.
