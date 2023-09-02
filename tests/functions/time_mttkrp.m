%{
Function to measure elapsed time HaCOO and Tensor Toolbox's MTTKRP operation.
Reports average times to a text file.

Input:
   file - a .txt file sparse tensor in COO format
   R - number of components in the decomposition
   outfile - name of file to write results to
   NUMTRIALS - number of trials to average times over
%}

function time_mttkrp(file, R, outfile, NUMTRIALS)

%File to time HaCOO vs Tensor Toolbox's MTTKRP function.

%file to write results to

%set up Tensor Toolbox sptensor
X = read_coo(file);

%set up HaCOO sptensor
T = read_htns(file);

%Set up U
N = T.nmodes;

Uinit = cell(N,1);

%this shold correspond to the number of components in the decomposition
col_sz = R;

for n = 1:N
    Uinit{n} = rand(T.modes(n),col_sz);
end

U = Uinit;

%store times for each mode
htns_elapsed = zeros(1,N);
tt_elapsed = zeros(1,N);
htns_cpu = zeros(1,N);
tt_cpu = zeros(1,N);

fprintf("HaCOO MTTKRP:\n")

for i = 1:NUMTRIALS
    fprintf("Trial %d\n",i);
    for n=1:N
        fprintf("MTTKRP over mode %d\n",n);
        f = @() htns_mttkrp(T,U,n); %<--matricize with respect to dimension n.
        tStart = cputime;
        htns_elapsed(n) = htns_elapsed(n) + timeit(f);
        tEnd = cputime - tStart;
        htns_cpu(n) = htns_cpu(n) + tEnd;
    end
end

fprintf("Tensor Toolbox COO MTTKRP:\n")
for i = 1:NUMTRIALS
    fprintf("Trial %d\n",i);
    for n=1:N
        fprintf("MTTKRP over mode %d\n",n);
        f = @() mttkrp(X,U,n);
        tStart = cputime;
        tt_elapsed(n) = tt_elapsed(n) + timeit(f);
        tEnd = cputime - tStart;
        tt_cpu(n) = tt_cpu(n) + tEnd;
    end
end

htns_elapsed= htns_elapsed/NUMTRIALS;
tt_elapsed= tt_elapsed/NUMTRIALS;
htns_cpu = htns_cpu/NUMTRIALS;
tt_cpu = tt_cpu/NUMTRIALS;

outFile = fopen(outfile,'w');

fprintf(outFile,"Averages calculated over %d trials.\n",NUMTRIALS);

fprintf(outFile,"Average elapsed time using HaCOO: \n");
for i=1:N
    fprintf(outFile,"Over mode %d: %f\n",i,htns_elapsed(i));
end

fprintf(outFile,"Average elapsed time using Tensor Toolbox: \n");
for i=1:N
    fprintf(outFile,"Over mode %d: %f\n",i,tt_elapsed(i));
end

fprintf(outFile,"Average CPU time using HaCOO: \n");
for i=1:N
    fprintf(outFile,"Over mode %d: %f\n",i,htns_cpu(i));
end

fprintf(outFile,"Average CPU time using Tensor Toolbox: \n");
for i=1:N
    fprintf(outFile,"Over mode %d: %f\n",i,tt_cpu(i));
end
