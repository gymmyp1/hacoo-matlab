% R = INNERPROD(X,Y) computes the inner product between
% HaCOO sparse tensor X and ktensor Y supported by Tensor Toolbox).
% If Y is a ktensor, the inner product is
% computed using inner products of the factor matrices, X{i}'*Y{i}.


function res = htns_innerprod(X,Y)
% check if X and Y are same size
if ~isequal(htns_size(X),size(Y))
    error('X and Y must be the same size.');
end

% Y is a ktensor
switch class(Y)

    case {'ktensor'}
        M = X.lambda * Y.lambda';
        for n = 1:ndims(X)
            M = M .* (X.u{n}' * Y.u{n});
        end
        res = sum(M(:));

    otherwise
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
end
end