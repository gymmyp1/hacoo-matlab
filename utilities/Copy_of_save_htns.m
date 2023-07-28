%Save a .txt COO tensor a HaCOO .mat file.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/


%files = ["uber.txt" "chicago.txt" "nips.txt" "lbnl.txt" "nell-2.txt" "enron.txt"];
files = ["enron.txt"];
concatFiles = ["enronConcat.txt"];


for i=1:length(files)
    tic
    fprintf("Saving tensor %s to file...\n", files(i));

    %if you only have COO file.
    %t = read_htns(files(i));

    t = read_htns(files(i),concatFiles(i))

    newStr = erase(files(i),".txt");
    matfile = strcat(newStr,'_hacoo.mat');

    write_htns(t,matfile);
    toc
end


