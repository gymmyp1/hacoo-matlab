function res = htns_ktns_innerprod(X,Y)

%INNERPROD Efficient inner product with a ktensor.
%
%   R = INNERPROD(X,Y) efficiently computes the inner product between
%   two tensors, ktensor X and HaCOO htensor Y.  
%   The inner product is computed using ttv with all of
%   the columns of X's factor matrices, X{i}.
%
%   See also KTENSOR, KTENSOR/TTV
%
%Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>

if ~isequal(size(X),Y.modes)
    error('X and Y must be the same size.');
end

% X is a ktensor
switch class(Y)

    case {'htensor'}
        R = length(X.lambda);
        vecs = cell(1,ndims(X));
        res = 0;
        for r = 1:R
            for n = 1:ndims(X)
                vecs{n} = X.u{n}(:,r);
            end
            res = res + X.lambda(r) * htns_ttv(Y,vecs);
        end

    otherwise
        disp(['Inner product not available for class ' class(Y)]);
end

%return

end