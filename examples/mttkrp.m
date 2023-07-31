%{ 

%}

idx = [1 1 1;
       1 2 0;
       2 1 0];

vals = [1, 2, 5];

%create the HaCOO tensor
X = htensor(idx,vals);

%Set up U
N = length(X.modes);
NUMTRIALS = 1;
dimorder = 1:N;
Uinit = cell(N,1);

%specify number of columns/number of components
col_sz = 50;

for n = 1:N
    Uinit{n} = rand(X.modes(n),col_sz);
end

U = Uinit;

%calculate MTTRKP over mode 1
V = htns_mttkrp(X,U,1)