%Returns the number of nonzero elements in HaCOO sparse tensor X.

function res = htns_nnz(X)
    res = X.hash_curr_size;
end