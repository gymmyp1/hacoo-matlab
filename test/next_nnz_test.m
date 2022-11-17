%Driver code for testing the next_nnz() function.

%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

file = 'y.txt';

t = read_htns(file)

startBucket = 1;
startRow = 0;

for i=1:t.hash_curr_size
    [bucket,row] = t.next_nnz(startBucket,startRow)
    disp(t.table{bucket}{row})
    startBucket = bucket;
    startRow = row;
end