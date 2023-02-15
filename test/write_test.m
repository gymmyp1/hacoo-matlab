%Testing write function for HaCOO .mat files

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

%writeTns('x.txt')
%writeTns('uber_trim.txt')
%writeTns('uber.txt')
%writeTns('chicago.txt')
%writeTns('enron.txt')
%writeTns('nips.txt')
writeTns('nell-2.txt')

toc

function writeTns(file)
    fprintf("Saving tensor %s to file...\n", file);
    t = read_htns(file);

    newStr = erase(file,".txt");
    matfile = strcat(newStr,'_hacoo.mat');

    write_htns(t,matfile);
end