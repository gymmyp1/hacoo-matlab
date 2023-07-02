%function [V,walltime,cpu_time] = htns_coo_mttkrp(X,U,n,nzchunk,rchunk,ver)

function V = htns_mttkrp(X,U,n,nzchunk,rchunk)

%MTTKRP Matricized tensor times Khatri-Rao product for sparse tensor.
%   This has been adapted to use sub and val matrices extracted from
%   a HaCOO htensor using the "retrieve" function. Everything else is
%   unchanged from the Toolbox version.
%
%   NOTICE: This internals of this code changed in Version 3.3 of Tensor
%   Toolbox to be much more efficient. It now "chunks" the nonzeros as well
%   as the factor matrices. Special options for this are described below.
%
%   V = MTTKRP(X,U,N) efficiently calculates the matrix product of the
%   n-mode matricization of X with the Khatri-Rao product of all
%   entries in U, a cell array of matrices, except the Nth.  How to
%   most efficiently do this computation depends on the type of tensor
%   involved.
%
%   V = MTTKRP(X,K,N) instead uses the Khatri-Rao product formed by the
%   matrices and lambda vector stored in the ktensor K. As with the cell
%   array, it ignores the Nth factor matrix. The lambda vector is absorbed
%   into one of the factor matrices.
%
%   V = MTTKRP(X,U,N,NZCHUNK,RCHUNK) specifies the "chunk" sizes for the
%   nonzeros and factor matrix columns, respectively. These default to
%   NZCHUNK=1e4 and RCHUNK=10 if not specified. If NZCHUNK=NNZ(X) and
%   RCHUNCK=SIZE(U{1},2), then it's just one big chunk.
%
%   Examples
%   S = sptensor([3 3 3; 1 3 3; 1 2 1], 4, [3, 4, 3]); %<-Declare sptensor
%   mttkrp(S, {rand(3,3), rand(3,3), rand(3,3)}, 2)
%
%   See also TENSOR/MTTKRP, SPTENSOR/TTV, SPTENSOR
%
%Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>

% In the sparse case, we do not want to form the Khatri-Rao product.

N = X.nmodes;

if isa(U,'ktensor')
    % Absorb lambda into one of the factors, but not the one that's skipped
    if n == 1
        U = redistribute(U,2);
    else
        U = redistribute(U,1);
    end
    % Extract the factor matrices
    U = U.u;
end

if (length(U) ~= N)
    error('Cell array is the wrong length');
end

if ~iscell(U)
    error('Second argument should be a cell array or a ktensor');
end

if (n == 1)
    R = size(U{2},2);
else
    R = size(U{1},2);
end

if ~exist('nzchunk','var')
    nzchunk = 1e4;
end
if ~exist('rchunk','var')
    rchunk = 10;
end

%fprintf("using chunked approach...\n");

flag = 0; %is this the first iteration? all other iterations we don't have to retrieve from the table any more.
nz = X.hash_curr_size;
d = X.nmodes;
nn = X.modes(n);


V = zeros(nn,R);
rctr = 0;

%since this processes rchunks at a time, we need space to save ceiling(R/rchunk) chunks of nonzeros
tempSubs = cell(1,ceil(R/rchunk));
tempVals = cell(1,ceil(R/rchunk));

while (rctr < R)

    % Process r range from rctr1 to rctr (columns of factor matrices)
    rctr1 = rctr + 1;
    rctr = min(R, rctr + rchunk);
    rlen = rctr - rctr1 + 1;

    nzctr = 0;
    itrNum = 1; %counter for revisiting nonzeros for a new rchunk
    startBucket = 1;
    startRow = 1;
    while (nzctr < nz)
        

        % Process nonzero range from nzctr1 to nzctr
        nzctr1 = nzctr+1;
        nzctr = min(nz,nzctr1+nzchunk);

        % ----

       
        if flag
            %we don't have to retrieve from the table again
            %fprintf("this is not the first iteration\n")

            %use our saved subs/vals instead of retrieving from the table
            subs = tempSubs{itrNum};
            vals = tempVals{itrNum};

        else
            %fprintf("This is the first iteration\n")
             %this is happening every rchunk, which slows it down. temporarily save results for other iterations
            [nnz,stopBucket,stopRow] = X.retrieve(nzctr-nzctr1+1,startBucket,startRow);
            subs = nnz(:,1:end-1);
            vals = nnz(:,end);

            startBucket = stopBucket;
            startRow = stopRow;

            %save result for later
            tempSubs{itrNum} = subs;
            tempVals{itrNum} = vals;
        end
        
        %{
        [nnz,stopBucket,stopRow] = X.retrieve(nzctr-nzctr1+1,startBucket,startRow); %this is happening every rchunk, which slows it down. maybe temporarily sabe thi
        subs = nnz(:,1:end-1);
        vals = nnz(:,end);

        startBucket = stopBucket;
        startRow = stopRow;
        %}

        Vexp = repmat(vals,1,rlen);

        for k = [1:n-1, n+1:d]
            Ak = U{k};
            Akexp = Ak(subs(:,k),rctr1:rctr);
            Vexp = Vexp .* Akexp;
        end
        for j = rctr1:rctr
            vj = accumarray(subs(:,n), Vexp(:,j-rctr1+1), [nn 1]);
            V(:,j) = V(:,j) + vj;
        end

        itrNum = itrNum + 1;
        % ----
    end
    flag = 1; %flip flag
end

end