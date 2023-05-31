%File to check HaCOO MTTKRP function.

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

%file = 'x.txt';
%T = read_htns(file); %<--HaCOO htensor

%file = 'uber_trim_hacoo.mat';
%T = load_htns(file);

%set up Tensor Toolbox sptensor
%table = readtable('x.txt');
table = readtable('uber_trim.txt');
idx = table(:,1:end-1);
vals = table(:,end);
idx = table2array(idx);
vals = table2array(vals);


X = sptensor(idx,vals);

T = htensor(X.subs,X.vals)

%Set up U
N = T.nmodes;
NUMTRIALS = N;
dimorder = 1:N;
Uinit = cell(N,1);

%this shold correspond to the number of components in the decomposition
col_sz = 5;

for n = 1:N
    Uinit{n} = rand(T.modes(n),col_sz);
end

U = Uinit;

%set up answers array
htns_ans = cell(NUMTRIALS,1);
tt_ans = cell(NUMTRIALS,1);

fprintf("Calculating HaCOO mttkrp...\n")

for n = 1:NUMTRIALS
    htns_ans{n} = spv_htns_mttkrp(T,U,n); %<--matricize with respect to dimension n.
end

fprintf("Calculating Tensor Toolbox mttkrp...\n")
for n = 1:NUMTRIALS
    tt_ans{n} = mttkrp(X,U,n); %<--matricize with respect to dimension i.
end
%{
%check if answers match
for i = 1:length(htns_ans)
    if htns_ans{i} == tt_ans{i}
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




