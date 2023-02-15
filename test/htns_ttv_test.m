%Testing htns_ttv (HaCOO tensor times vector) function.

%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

%Create random sptensor
S = sptensor(rand(3,4,2));
T = htensor(S.subs,S.vals);

X =  cell(T.nmodes,1);

%Create column vectors of appropriate size
for i=1:T.nmodes
    X{i} = rand(T.modes(i),1);
end

ans1 = ttv(S,X);
ans2 = htns_ttv(T,X);



