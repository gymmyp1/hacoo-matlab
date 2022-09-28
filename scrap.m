%Draft code for CP ALS implementation

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
% M = CP_ALS(X,R,'param',value,...) specifies optional parameters and
%   values. Valid parameters and their default values are:
%      'tol' - Tolerance on difference in fit {1.0e-4}
%      'maxiters' - Maximum number of iterations {50}
%      'dimorder' - Order to loop through dimensions {1:ndims(A)}
%      'init' - Initial guess [{'random'}|'nvecs'|cell array]
%      'printitn' - Print fit every n iterations; 0 for no printing {1}
%      'fixsigns' - Call fixsigns at end of iterations {true}

function M = scrap(X,R)
%random initialization of U
% Observe that we don't need to calculate an initial guess for the
% first index in dimorder because that will be solved for in the first
% inner iteration.

N = X.nmodes;
normX = tns_norm(X);

%% Set algorithm parameters from input or by using defaults
dimorder = 1:N; %Order to loop through dimensions {1:ndims(A)}
maxiters = 50;
fitchangetol = 1e-4;

%% Set up and error checking on initial guess for U.
Uinit = cell(N,1);

for n = dimorder(2:end)
    Uinit{n} = rand(X.modes(n),R);
end

Uinit
M = 1;
end %end function