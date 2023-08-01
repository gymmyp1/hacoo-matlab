%File to time HaCOO vs Tensor Toolbox's MTTKRP function.

file = "uber.txt";

fprintf("Initializing Tensor Toolbox sptensor...\n");
%set up Tensor Toolbox sptensor
X = read_coo(file);

fprintf("Initializing HaCOO htensor...\n");
%set up HaCOO sptensor
T = read_htns(file);

%Set up U
N = T.nmodes;
NUMTRIALS = 10;

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
htns_cpu = zeros(1,N);
tt_cpu = zeros(1,N);

fprintf("Calculating HaCOO mttkrp...\n")

for i = 1:NUMTRIALS
    fprintf("Trial %d\n",i);
    for n=1:N
        fprintf("MTTKRP over mode %d\n",n);
        f = @() htns_mttkrp(T,U,n); %<--matricize with respect to dimension n.
        tStart = cputime;
        t = timeit(f);
        htns_elapsed(n) = htns_elapsed(n) + t;
        tEnd = cputime - tStart;
        htns_cpu(n) = htns_cpu(n) + tEnd;
    end
end

fprintf("Calculating Tensor Toolbox mttkrp...\n")
for i = 1:NUMTRIALS
    fprintf("Trial %d\n",i);
    for n=1:N
        fprintf("MTTKRP over mode %d\n",n);
        f = @() mttkrp(X,U,n); %<--matricize with respect to dimension n.
        tStart = cputime;
        t = timeit(f);
        tt_elapsed(n) = tt_elapsed(n) + t;
        tEnd = cputime - tStart;
        tt_cpu(n) = tt_cpu(n) + tEnd;
    end
end

htns_elapsed= htns_elapsed/NUMTRIALS;
tt_elapsed= tt_elapsed/NUMTRIALS;
htns_cpu = htns_cpu/NUMTRIALS;
tt_cpu = tt_cpu/NUMTRIALS;

outFile = fopen(outFileName,'w');

fprintf("Averages calculated over %d trials.\n",NUMTRIALS);

fprintf("Average elapsed time using HaCOO: \n");
for i=1:N
    fprintf("Over mode %d: %f\n",i,htns_elapsed(i));
end

fprintf("Average elapsed time using Tensor Toolbox: \n");
for i=1:N
    fprintf("Over mode %d: %f\n",i,tt_elapsed(i));
end

fprintf("Average CPU time using HaCOO: \n");
for i=1:N
    fprintf("Over mode %d: %f\n",i,htns_cpu(i));
end

fprintf("Average CPU time using Tensor Toolbox: \n");
for i=1:N
    fprintf("Over mode %d: %f\n",i,tt_cpu(i));
end