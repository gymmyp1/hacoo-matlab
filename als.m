%Draft code for ALS implementation

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

%file = 'uber.txt';
file = 'test2.txt';

table = readtable(file);

idx = table(:,1:end-1);
vals = table(:,end);

t = hacoo(idx,vals);

% Computes an estimate of the best rank-R
% CP model of a tensor X using an alternating least-squares algorithm. 
%
% Parameters:
%       X - a sparse tensor of HaCOO data type
%       R - the desired number of components in the CP decomposition
% Returns:
%       M - Kruskal format tensor decomposition of a tensor X as the 
%           sum of the outer products as the columns of matrices
%
function M = als(X,R)
    %random initialization of U
       % Observe that we don't need to calculate an initial guess for the
    % first index in dimorder because that will be solved for in the first
    % inner iteration.
    N = ndims(X);
    normX = norm(X);

    Uinit = cell(N,1);
    for n = dimorder(2:end)
        Uinit{n} = rand(size(X,n),R);
    end

    for n = 1:N
         U{n} = Unew;
         UtU(:,:,n) = U{n}'*U{n};

        A(n) = mttkrp(X,U,n) * V.T
        %normalize columns of A_(n)
    end

    %check if fit has not improved or if max number of interations
    % has been reached

    %return lambda, A^(1)...A^(N)

end %end function


end