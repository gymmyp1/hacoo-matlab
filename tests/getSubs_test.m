%testing which method is faster to retrieve all elements from hash table.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

t = read_htns('chicago.txt');

%-----------

%get the locations of nonempty cells
nnzLoc = find(~cellfun(@isempty,t.table));

tic
%extract only nonempty cells
nnz = t.table(nnzLoc);
%nnzInd = nnz{1}
%nnz(1:end,:)
%nnz{1:end,:}
vertcat(nnz{1:end,:});
%A = [nnz{1:end,:};]

%cellfun(@(a) disp(a),nnz)
toc

%-----------

tic
%get subs usual way
[subs,vals] = t.all_subsVals();
toc

%-----------

%uber:
%extract using find,indexing on array, converting back to matrix: 1.779042 seconds.
%extract using traditional loop: 6.972742 seconds.

%chicago:
%extract using find,indexing on array, converting back to matrix: 8.930159 seconds.
%extract using traditional loop: 14.118482 seconds.