%R = INNERPROD(X,Y) computes the inner product between
%   two tensors X and Y.

function htns_innerprod(X,Y)
    % check if X and Y are same size
    if ~isequal(size(X),size(Y))
            error('X and Y must be the same size.');
    end

    %For each mode 
   

end