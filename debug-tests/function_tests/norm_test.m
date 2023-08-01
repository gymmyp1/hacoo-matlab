%Driver code for testing the tns_norm() function for
% the htensor(HaCOO) class against Tensor Toolbox's norm().

file = 'y.txt';
table = readtable(file);
arr = table2array(table);

idx = arr(:,1:end-1);
vals = arr(:,end);

%create tensor tool box sptensor
X = sptensor(idx,vals);

t = read_htns(file);

%check if the answers are the same
htns_norm(t)
norm(X)