%INNERPROD Efficient inner product with a sparse tensor.
%
%   R = INNERPROD(X,Y) efficiently computes the inner product between
%   two tensors X and Y.  If Y is a tensor or sptensor, the inner
%   product is computed directly and the computational complexity is
%   O(min(nnz(X),nnz(Y))). If Y is a ktensor or a ttensor, the
%   inner product method for that type of tensor is called.
%
%   See also SPTENSOR, KTENSOR/INNERPROD, TTENSOR/INNERPROD.
%
%Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>


function res = htns_innerprod(X,Y)

%X is a HaCOO htensor
switch class(Y)

    case {'ktensor','ttensor'}
        %Reverse the inputs to call ktensor/ttensor implementation
        res = htns_ktns_innerprod(Y,X);
        return;

    case {'sptensor'}

        % check if X and Y are same size
        if ~isequal(htns_size(X),size(Y))
            error('X and Y must be the same size.');
        end


        if nnz(Y) == 0 %There are no nonzero terms in Y.
            res = 0;
            return
        end

        if htns_nnz(X) < nnz(Y)
            [SX,VX] = htns_find(X);
            VY = extract(Y,SX);   %<-----VY = Y(SX);
        else
            [SY,VY] = find(Y);
            VX = htns_extract(X,SY);   %<-----VX = X(SY);
        end
        res = VY'*VX;
        return;

    otherwise
        error(['Inner product not available for class ' class(Y)]);
end


end