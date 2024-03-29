%{
Carry out mttkrp using the Sparse Vector method between the tensor 
and an array of matrices unfolding the tensor along mode n. This is very
slow.

Parameters:
    u - A list of matrices, these correspond to the modes
	    in the tensor, other than n. If i is the dimension in
	    mode x, then u(x) must be an i x f matrix.
    n - The mode along which the tensor is unfolded for the
	    product.
    varargin - optionally pass index and value arrays as the 4th and 5th
               arguments respectively
Returns:
    m - Result matrix with dimensions i_n x f
%}

function m = spv_htns_mttkrp(T,u,n)

% number of columns
fmax = size(u{1},2);

% create the result array
m = zeros(T.modes(n), fmax);

% go through each column
for f=1:fmax
    % preallocate accumulation arrays
    t = zeros(1,T.hash_curr_size);
    tind = zeros(1,T.hash_curr_size);
    ac = 1; %counter for accumulation arrays
    b = 1; %bucket index

    % go through every bucket
    while b ~= -1

        %go through every entry in that bucket
        for j=1:size(T.table{b},1)

            nnz = T.table{b}(j,:);
            idx = nnz(1:end-1);
            val = nnz(end);

            t(ac) = val;
            tind(ac) = idx(n);
            ac = ac + 1; %advance counter
            z = ac-1;

            % multiply by each factor matrix except the nth matrix
            for i=1:size(u,1) %<-- for each matrix in u
                % skip the unfolded mode
                if i==n
                    continue
                end

                % multiply the factor and advance to the next
                t(z) = u{i}(idx(i), f) * t(z);
            end
        end

        %update bucket to next occupied bucket
        b = T.next(b);
    end
    
    % accumulate m(:,f)
    for p=1:T.hash_curr_size
        m(tind(p),f) = m(tind(p), f) + t(p);
    end
end

end %<-- end function