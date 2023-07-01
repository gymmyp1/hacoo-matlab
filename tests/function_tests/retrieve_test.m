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

%[nnz,stopBucket,stopRow] = t.retrieve2(3,startBucket,startRow);

%nnz


while (acc_nnz < nz)
    [nnz,stopBucket,stopRow] = t.retrieve2(nzchunk,startBucket,startRow);
    %disp(nnz)
    startBucket = stopBucket;
    startRow = stopRow;
    fprintf("new start bucket: %d\n",startBucket)
    fprintf("new start row: %d\n",startRow)
    acc_nnz = acc_nnz+nzchunk;
end


