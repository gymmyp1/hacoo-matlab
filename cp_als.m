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
function M = cp_als(X,R)
    %random initialization of U
    % Observe that we don't need to calculate an initial guess for the
    % first index in dimorder because that will be solved for in the first
    % inner iteration.

    N = ndims(X);
    normX = tns_norm(X);

    Uinit = cell(N,1);
    for n = 2:N
        Uinit{n} = rand(X.modes(n),R);
    end

%% Set up for iterations - initializing U and the fit.
U = Uinit;
fit = 0;

% Store the last MTTKRP result to accelerate fitness computation.
U_mttkrp = zeros(size(X, dimorder(end)), R); %what's dimorder???

    for n = 1:N
         U{n} = 
         UtU(:,:,n) = U{n}'*U{n};

        %A(n) = mttkrp(X,U,n) * UtU
        %normalize columns of A_(n)
    end

    %check if fit has not improved or if max number of interations
    % has been reached

    %return lambda, A^(1)...A^(N)

end %end function