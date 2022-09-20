%R = INNERPROD(X,Y) computes the inner product between
%   two tensors X and Y.

function innerprod(X,Y)
    % check if X and Y are same size
    if ~isequal(size(X),size(Y))
            error('X and Y must be the same size.');
    end

   

end