%Driver code for testing the retrieve() function.

%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%{
file = 'y.txt';
t = read_htns(file);
%}

file = 'ubertrim_hacoo.mat';
fprintf("Loading HaCOO .mat file.\n");
t = load_htns(file);
fprintf("Finished loading.\n");

startBucket = 1;
startRow = 1;

nz = t.hash_curr_size;
nzchunk = 1e4;
%nzchunk = 5;
nzctr = 0;

while (nzctr < nz)
    % Process nonzero range from nzctr1 to nzctr
    nzctr1 = nzctr+1;
    nzctr = min(nz,nzctr1+nzchunk);
    [subs,vals,stopBucket,stopRow] = t.retrieve(nzctr-nzctr1+1,[startBucket,startRow]);
    disp(subs)
    startBucket = stopBucket;
    startRow = stopRow+1; %since we want to get the next nnz past where we stopped previously
end
