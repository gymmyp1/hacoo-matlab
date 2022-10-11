%Test correctness of htns_innerprod function.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

%set up answers array
htns_ans = {};
tt_ans = {};


%set up 10 trials
for n = 1:10
    %set up random sptensor
    X = sptensor(rand(2,1,4));
    A = htensor(X.subs,X.vals);

    htns_ans{end+1} = htns_innerprod(A,X);
    tt_ans{end+1} = innerprod(X,X);
end

%check if answers match
for i = 1:length(htns_ans)
    
    if htns_ans{i} == tt_ans{i}
        fprintf("solutions match.\n");
    else 
        fprintf("solution does not match.\n");
        fprintf("hacoo mttkrp ans: \n");
        disp(htns_ans{i});
        fprintf("tensor toolbox mttkrp ans: \n");
        disp(tt_ans{i});
    end
end