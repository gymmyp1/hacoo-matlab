%R = INNERPROD(X,Y) computes the inner product between
%   two tensors X and Y.

function innerprod(X,Y)
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