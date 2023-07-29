%test speed of reading COO to HaCOO

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/


%files = ["uber.txt" "chicago.txt" "nips.txt" "lbnl.txt" "nell-2.txt" "enron.txt"];
files = ["lbnl.txt" "nips.txt"];

%concatFiles = ["enronConcat.txt"];


for i=1:length(files)
    tic
    fprintf("Reading tensor %s...\n", files(i));

    %if you only have COO file.
    t = read_htns(files(i));
    fprintf("max chain depth: %d\n",t.max_chain_depth);
    %newStr = erase(files(i),".txt");
    %matfile = strcat(newStr,'_hacoo.mat');

    %write_htns(t,matfile);
    toc
end


