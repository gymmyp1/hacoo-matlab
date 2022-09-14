addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\tensor_toolbox-v3.3\

subs = [1,1,1;
        2,1,1;
        1,2,1;
        2,2,1;
        1,1,2;
        2,1,2;
        1,2,2;
        2,2,2];

subs2 = [1,1,1;
        2,1,1;
        1,2,1;
        2,2,1;
        1,1,2;
        2,1,2;
        1,2,2;
        2,2,2];

vals = [1;1;2;1;1;1;2;1];

vals2 = [1;1;2;1;1;2;2;2];

X = sptensor(subs,vals); %<-- Or, specify the size explicitly.
Y = sptensor(subs2,vals2);

z = innerprod(X,Y) %<-- z = 2.4751

%create hacoo tensor with same values
file1 = 'x.txt';
file2 = 'y.txt';

table1 = readtable(file1);
table2 = readtable(file2);

idx1 = table1(:,1:end-1);
vals1 = table1(:,end);

idx2 = table2(:,1:end-1);
vals2 = table2(:,end);

modes1 = [2,2,2];
modes2 = [2,2,2];

t1 = hacoo(idx1,vals1,modes1);
t2 = hacoo(idx2,vals2,modes2);

%display_tns(t1);
%display_tns(t2);

t1.get([1,1,1])

%test mine
%my_z = inner_prod(X,Y)

function res = inner_prod(X,Y)
    % check if X and Y are same size
    if ~isequal(size(X),size(Y))
            error('X and Y must be the same size.');
    end

    %loop over each mode
    for r = 1:ndims(X)
        for n = 1:size(X,r)
            res = res + (X)
        end
    end

    %loop over each nnz entry from 1 to the max index in that mode
end