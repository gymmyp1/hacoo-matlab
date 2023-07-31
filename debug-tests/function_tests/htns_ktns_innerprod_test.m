%Test correctness of htns_ktns_innerprod function.

%set up answers array
NUMTRIALS = 10;
htns_ans = cell(NUMTRIALS,1);
tt_ans = cell(NUMTRIALS,1);


%set up trials
for n = 1:NUMTRIALS
    %set up random tensors
    S = sptensor(rand(3,4,2));
    Y = htensor(S.subs,S.vals);
    X = ktensor({rand(3,1),rand(4,1),rand(2,1)});
    

    htns_ans{n} = htns_ktns_innerprod(X,Y);
    tt_ans{n} = innerprod(X,S);
end

%check if answers match
for i = 1:NUMTRIALS
    
    if htns_ans{i} == tt_ans{i}
        fprintf("solutions match.\n");
    else 
        fprintf("solution does not match.\n");
        fprintf("hacoo ans: \n");
        disp(htns_ans{i});
        fprintf("tensor toolbox ans: \n");
        disp(tt_ans{i});
    end
end