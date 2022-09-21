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

function M = cp_als(X,R)
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


%% Set up for iterations - initializing U and the fit.
U = Uinit;
fit = 0;

% Store the last MTTKRP result to accelerate fitness computation.
U_mttkrp = zeros(size(X, dimorder(end)), R); %what's dimorder???

UtU = zeros(R,R,N);

for n = 1:N
    if ~isempty(U{n})
        UtU(:,:,n) = U{n}'*U{n};
    end
end


 for iter = 1:maxiters
        
        fitold = fit;
        
        % Iterate over all N modes of the tensor
        for n = dimorder(1:end)
            
            % Calculate Unew = X_(n) * khatrirao(all U except n, 'r').
            Unew = mttkrp(X,U,n);
            % Save the last MTTKRP result for fitness check.
            if n == dimorder(end)
              U_mttkrp = Unew;
            end
            
            % Compute the matrix of coefficients for linear system
            Y = prod(UtU(:,:,[1:n-1 n+1:N]),3);
            Unew = Unew / Y;
            if issparse(Unew)
                Unew = full(Unew);   % for the case R=1
            end
                        
            % Normalize each vector to prevent singularities in coefmatrix
            if iter == 1
                lambda = sqrt(sum(Unew.^2,1))'; %2-norm
            else
                lambda = max( max(abs(Unew),[],1), 1 )'; %max-norm
            end            
            
            Unew = bsxfun(@rdivide, Unew, lambda');

            U{n} = Unew;
            UtU(:,:,n) = U{n}'*U{n};
        end
        
        P = ktensor(lambda,U);

        % This is equivalent to innerprod(X,P).
        iprod = sum(sum(P.U{dimorder(end)} .* U_mttkrp) .* lambda');
        if normX == 0
            fit = norm(P)^2 - 2 * iprod;
        else
            normresidual = sqrt( normX^2 + norm(P)^2 - 2 * iprod );
            fit = 1 - (normresidual / normX); %fraction explained by model
        end
        fitchange = abs(fitold - fit);
        
        % Check for convergence
        if (iter > 1) && (fitchange < fitchangetol)
            flag = 0;
        else
            flag = 1;
        end
        
        if (mod(iter,printitn)==0) || ((printitn>0) && (flag==0))
            fprintf(' Iter %2d: f = %e f-delta = %7.1e\n', iter, fit, fitchange);
        end
        
        % Check for convergence
        if (flag == 0)
            break;
        end        
    end   
end %end function