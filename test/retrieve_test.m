%Driver code for testing the retrieve() function.

%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

file = 'y.txt';

t = read_htns(file);

startBucket = 1;
startRow = 1;

[subs,vals,i,j] = t.retrieve(4,[startBucket,startRow]);
disp(subs)
startBucket = i;
startRow = j+1;

[subs,vals,i,j] = t.retrieve(4,[startBucket,startRow]);
disp(subs)

