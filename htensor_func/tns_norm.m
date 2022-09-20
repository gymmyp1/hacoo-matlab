% Returns the norm of a sparse tensor
% Method in Efficient MATLAB Computations for Sparse Tensors by Kolda

%need to check if this is correct...
%need to vectorize sqrt(abs(sum(...)))

%Input:
%       t - a HaCOO sparse tensor
%Returns:
%       n - the norm of the sparse tensor
%

function n = tns_norm(t)
    %function not implemented yet

    n = 0;
    for i = 1:t.nbuckets

        %skip bucket if empty

        for j = 1:length(t.table{i})
            %Accumulate sum
            n = n + power(t.table{i}{j}.value,2);
        end
    end
    n = sqrt(n);
end