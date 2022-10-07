%R = INNERPROD(X,Y) computes the inner product between
%   HaCOO sparse tensor X and tensor Y.

function res = htns_innerprod(X,Y)
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
        VX = extract(X,SY);   %<-----VX = X(SY);
    end
    res = VY'*VX;
    return;
   

end