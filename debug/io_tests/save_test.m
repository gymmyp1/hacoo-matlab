%Save a .txt COO tensor a HaCOO .mat file.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

writeTns('uber.txt')


toc

function writeTns(file)
    fprintf("Saving tensor %s to file...\n", file);
    t = read_htns(file);

    newStr = erase(file,".txt");
    matfile = strcat(newStr,'_hacoo.mat');

    write_htns(t,matfile);
end