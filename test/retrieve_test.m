%code for testing the retrieve() function.

%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

%file = 'y.txt';
%t = read_htns(file);


file = 'uber_trim_hacoo.mat';
fprintf("Loading HaCOO .mat file.\n");
t = load_htns(file);
fprintf("Finished loading.\n");


startBucket = 1;
startRow = 1;

nz = t.hash_curr_size;
%nzchunk = 1e4;
nzchunk = 3;
nzctr = 0;

[subs,vals,stopBucket,stopRow] = t.retrieve(1001,startBucket,startRow);

size(vals,1)
size(vals,2)

%{
while (nzctr < nz)
    [subs,vals,stopBucket,stopRow] = t.retrieve(nzchunk,[startBucket,startRow]);
    disp(subs)
    startBucket = stopBucket;
    startRow = stopRow;
    nzctr = nzctr+nzchunk;
end
%}
