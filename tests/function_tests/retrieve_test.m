%code for testing the retrieve() function.

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

file = 'y.txt';
t = read_htns(file);


%{
file = 'uber_trim_hacoo.mat';
fprintf("Loading HaCOO .mat file.\n");
t = load_htns(file);
fprintf("Finished loading.\n");
%}

startBucket = 1;
startRow = 1;

nz = t.hash_curr_size;
%nzchunk = 1e4;
nzchunk = 3;
acc_nnz = 0;

%[subs,vals,stopBucket,stopRow] = t.retrieve(3,startBucket,startRow);

%subs
%vals

while (acc_nnz < nz)
    [subs,vals,stopBucket,stopRow] = t.retrieve(nzchunk,startBucket,startRow);
    disp(subs)
    startBucket = stopBucket;
    startRow = stopRow;
    acc_nnz = acc_nnz+nzchunk;
end


