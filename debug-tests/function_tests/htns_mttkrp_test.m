%File to verify correctness of HaCOO MTTKRP function.

%file = 'uber_trim_hacoo.mat';
%T = load_htns(file);

file = ('uber_trim.txt');

%set up Tensor Toolbox sptensor
X = read_coo(file);

%set up HaCOO tensor
T = read_htns(file);

%Set up U
N = length(T.modes);
NUMTRIALS = 1;
dimorder = 1:N;
Uinit = cell(N,1);

%this shold correspond to the number of components in the decomposition
col_sz = 50;

for n = 1:N
    Uinit{n} = rand(T.modes(n),col_sz);
end

U = Uinit;

%set up answers array
htns_ans = cell(NUMTRIALS,N);
tt_ans = cell(NUMTRIALS,N);

fprintf("Calculating HaCOO mttkrp...\n")

for n = 1:NUMTRIALS
    for m=1:N
        htns_ans{n,m} = htns_mttkrp(T,U,m); %<--matricize with respect to dimension n.
    end
end

fprintf("Calculating Tensor Toolbox mttkrp...\n")
for n = 1:NUMTRIALS
    for m=1:N
        tt_ans{n,m} = mttkrp(X,U,m); %<--matricize with respect to dimension i.
    end
end

%check if answers match within a specified tolerance
for i = 1:length(htns_ans)

    if ismembertol(htns_ans{i},tt_ans{i},0.005)
        fprintf("Solutions match.\n");
    else
        prompt = "Solutions do not match. Write results? Y/N: ";
        p = input(prompt,"s");
        if p == "Y" || p == "y"
            %fprintf("HaCOO MTTKRP ans: \n");
            %disp(htns_ans{i});
            %fprintf("Tensor Toolbox MTTKRP ans: \n");
            %disp(tt_ans{i});
            writematrix(htns_ans{i},'htns_ans.txt','Delimiter','space')
            writematrix(tt_ans{i},'tt_ans.txt','Delimiter','space')
        else
            break
        end
    end
end




