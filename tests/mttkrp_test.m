%Time HaCOO and Tensor Toolbox's MTTKRP function.

file = "uber.txt";

fprintf("Initializing Tensor Toolbox sptensor...\n");
%set up Tensor Toolbox sptensor
X = read_coo(file);

fprintf("Initializing HaCOO htensor...\n");
%set up HaCOO sptensor
T = read_htns(file);

%Set up U
N = length(T.modes);

dimorder = 1:N;
Uinit = cell(N,1);

%this shold correspond to the number of components in the decomposition
col_sz = 50;

for n = 1:N
    Uinit{n} = rand(T.modes(n),col_sz);
end

U = Uinit;

%store times for each mode
htns_elapsed = zeros(1,N);
tt_elapsed = zeros(1,N);

fprintf("HaCOO MTTKRP: \n");

for n=1:N
    fprintf("MTTKRP over mode %d\n",n);
    f = @() htns_mttkrp(T,U,n); %<--matricize with respect to dimension n.
    tStart = cputime;
    t = timeit(f);
    htns_elapsed(n) = t;
end

fprintf("Tensor Toolbox MTTKRP: \n");

for n=1:N
    fprintf("MTTKRP over mode %d\n",n);
    f = @() mttkrp(X,U,n); %<--matricize with respect to dimension n.
    tStart = cputime;
    t = timeit(f);
    tt_elapsed(n) = t;
end

fprintf("Elapsed time using HaCOO: \n");
for i=1:N
    fprintf("Over mode %d: %f\n",i,htns_elapsed(i));
end

fprintf("Elapsed time using Tensor Toolbox: \n");
for i=1:N
    fprintf("Over mode %d: %f\n",i,tt_elapsed(i));
end