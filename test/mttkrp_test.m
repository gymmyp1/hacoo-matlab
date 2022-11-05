%File to check HaCOO MTTKRP function.

%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

%file = 'y.txt';
%T = read_htns(file); %<--HaCOO htensor

file = 'ubertrim_hacoo.mat';
T = load_htns(file);

%set up Tensor Toolbox sptensor
%table = readtable(file);
table = readtable('uber_trim.txt');
idx = table(:,1:end-1);
vals = table(:,end);
idx = table2array(idx);
vals = table2array(vals);

X = sptensor(idx,vals);

%Set up U
N = T.nmodes;
dimorder = 1:N;
Uinit = cell(N,1);

%this shold correspond to the number of components in the decomposition
col_sz = 2; 

for n = 1:N
    Uinit{n} = rand(T.modes(n),col_sz);
end

U = Uinit;

%Error check
%if (length(U) ~= N)
%    error('Cell array is the wrong length');
%end

%set up answers array
htns_ans = {};
tt_ans = {};

for n = 1:T.nmodes
    htns_ans{end+1} = htns_mttkrp(T,U,n); %<--matricize with respect to dimension n.
end

for n = 1:T.nmodes
    tt_ans{end+1} = mttkrp(X,U,n); %<--matricize with respect to dimension i.
end

%{
%check if answers match
for i = 1:length(htns_ans)

    if htns_ans{i} == tt_ans{i}
        fprintf("solutions match.\n");
    else 
        fprintf("solution does not match.\n");
        %fprintf("hacoo mttkrp ans: \n");
        %disp(htns_ans{i});
        %fprintf("tensor toolbox mttkrp ans: \n");
        %disp(tt_ans{i});
    end
end
%}