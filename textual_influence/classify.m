
%{
Target paper: Serfas, Doug- Dynamic Biometric Recognition of Handwritten 
Digits Using Symbolic Aggregate Approximation (2017 ACM Proceedings Southeast Conference)
%}

%list of documents in corpus
files = ["lin_sax_coo.txt" "serfas_dynamicbiometric_coo.txt"];
%files = ["lin_sax_coo.txt" "schlapbach_hmm_coo.txt" "gazzah_arabic_coo.txt" "manabe_identity_coo.txt" "kolda_multilinear_coo.txt" "blei_latent_coo.txt" "serfas_dynamicbiometric_coo.txt"];

ndocs = length(files);
C = {}; %list of document tensors

%nfactors = 150;
nfactors = 1;
threshold = 0.2;

%for each document in the corpus create sptensor from COO file
for i=1:ndocs
    C{end+1} = read_coo(files(i));
end

[V, F] = extract_factors(C,nfactors)
M = distance_matrix(F)
%[W,S] = extract_influence(ndocs, M, V, threshold)
%[I,author] = final_summation(ndocs,S,W)