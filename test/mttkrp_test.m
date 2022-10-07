%File to check HaCOO MTTKRP function.

%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

%{
a = [1 3 5; 2 4 6];
b = [1 4 7; 2 5 8; 3 6 9];
c = [1 2 3; 4 5 6; 7 8 9; 10 11 12];
U = cell(1,modes);
U{1} = a;
U{2} = b;
U{3} = c;
%}

file = 'y.txt';
T = read_htns(file); %<--HaCOO htensor

%set up Tensor Toolbox sptensor
table = readtable(file);
idx = table(:,1:end-1);
vals = table(:,end);
idx = table2array(idx);
vals = table2array(vals);

X = sptensor(idx,vals);

%Set up U
N = T.nmodes;
dimorder = 1:N;
Uinit = cell(N,1);

%{
for n = 1:N
    Uinit{n} = randi([1,3],T.modes(n),N);
end
%}
Uinit{1} = [2 3 1; 3 1 1];
Uinit{2} = [3 2 2; 2 3 1; 2 2 2];
Uinit{3} = [1 1 2];

U = Uinit;

%Error check
if (length(U) ~= N)
    error('Cell array is the wrong length');
end

%set up answers array
htns_ans = {};
tt_ans = {};

for n = 1:T.nmodes
    htns_ans{end+1} = htns_mttkrp(T,U,n); %<--matricize with respect to dimension n.
end

for n = 1:T.nmodes
    tt_ans{end+1} = mttkrp(X,U,n); %<--matricize with respect to dimension i.
end

%check if answers match
for i = 1:length(htns_ans)

    if htns_ans{i} == tt_ans{i}
        fprintf("solutions match.\n");
    else 
        fprintf("solution does not match.\n");
    end
    fprintf("hacoo mttkrp ans: \n");
    disp(htns_ans{i});
    fprintf("tensor toolbox mttkrp ans: \n");
    disp(tt_ans{i});
end