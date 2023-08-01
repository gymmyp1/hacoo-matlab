%File to check correctness of HaCOO MTTKRP function.

file = 'uber.txt';

%set up Tensor Toolbox sptensor
%X = read_coo(file);

%set up HaCOO tensor
%T = read_htns(file);

%Set up U
N = T.nmodes;
NUMTRIALS = 1;
dimorder = 1:N;
Uinit = cell(N,1);

%this shold correspond to the number of components in the decomposition
col_sz = 5;

for n = 1:N
    Uinit{n} = rand(T.modes(n),col_sz);
end

U = Uinit;

%set up answers array
htns_ans = cell(NUMTRIALS,N);
tt_ans = cell(NUMTRIALS,N);

fprintf("Calculating HaCOO mttkrp...\n")

for n = 1:NUMTRIALS
    for m = 1:N
        tic
        htns_ans{n,m} = spv_htns_mttkrp(T,U,m); %<--matricize with respect to dimension m.
        toc
    end
end

fprintf("Calculating Tensor Toolbox mttkrp...\n")
for n = 1:NUMTRIALS
    for m = 1:N
        tic
        tt_ans{n,m} = mttkrp(X,U,m); %<--matricize with respect to dimension m.
        toc
    end
end

htns_ans
tt_ans

%check if answers match within a specified tolerance
for i = 1:length(htns_ans)
    
    if ismembertol(htns_ans{i},tt_ans{i},0.00005)
        fprintf("Solutions match.\n");
    else
        prompt = "Solutions do not match. Print results? Y/N: ";
        p = input(prompt,"s");
        if p == "Y" || p == "y"
            fprintf("HaCOO MTTKRP ans: \n");
            disp(htns_ans{i});
            fprintf("Tensor Toolbox MTTKRP ans: \n");
            disp(tt_ans{i});
            writematrix(htns_ans{i},'htns_ans.txt','Delimiter','space')
            writematrix(tt_ans{i},'tt_ans.txt','Delimiter','space')
        else
            break
        end
    end
end

%}