%Returns the size of mode n of sparse tensor X.
%Temporary to work with Tensor Toolbox.

function size = htns_size(X,n)
    size = X.modes(n);
end