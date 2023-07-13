%Save a .txt COO tensor a HaCOO .mat file.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic

%Just change these file names to what you need.
%-------
file = "uber.txt";
concatIdxFile = "uber_concat.txt";
%--------

fprintf("Saving tensor %s to file...\n", file);

%if you only have COO file.
%t = read_htns(file);

%If you have indexes already concatenated...
t = read_htns(file,concatIdxFile);

newStr = erase(file,".txt");
matfile = strcat(newStr,'_hacoo.mat');

write_htns(t,matfile);

toc

