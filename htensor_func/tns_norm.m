% The norm of a tensor X ∈ RI1×I2×···×IN is the square root of the 
% sum of the squares of all its elements.

%Input:
%       t - a HaCOO sparse tensor
%Returns:
%       n - the norm of the sparse tensor
%

%need to check if this is correct
function res = tns_norm(t)
    res = norm(t.get_vals()); %<-- Apply norm to all nnz vals
end