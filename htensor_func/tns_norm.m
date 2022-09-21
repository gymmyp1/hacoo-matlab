% Returns the norm of a sparse tensor
% Method in Efficient MATLAB Computations for Sparse Tensors by Kolda

%Input:
%       t - a HaCOO sparse tensor
%Returns:
%       n - the norm of the sparse tensor
%

function res = tns_norm(t)
    res = norm(t.get_vals()); %<-- Apply norm to all nnz vals
end