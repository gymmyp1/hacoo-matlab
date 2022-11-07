%{
Carry out mttkrp between the tensor and an array of matrices,
unfolding the tensor along mode n.

Parameters:
    u - A list of matrices, these correspond to the modes
	    in the tensor, other than n. If i is the dimension in
	    mode x, then u(x) must be an i x f matrix.
    n - The mode along which the tensor is unfolded for the
	    product.
Returns:
    m - Result matrix with dimensions i_n x f
%}

function m = htns_mttkrp(T,u,n)

% number of columns
fmax = size(u{1},2);
    
% create the result array
m = zeros(T.modes(n), fmax);

% go through each column
for f=1:fmax
    % preallocate accumulation arrays
    t=zeros(1,T.hash_curr_size);
    tind=zeros(1,T.hash_curr_size);
    ac = 1; %counter index for accumulation arrays    

    % go through every non-zero
    for k=1:T.nbuckets
        if isempty(T.table{k})
            continue
        end
        for j=1:size(T.table{k},1)  %<-- loop over each entry in that bucket

            idx = T.table{k}{j};

            t(ac) = T.table{k}{j,2};
            tind(ac) = idx(n);
            ac = ac + 1; %next index to insert into
            
            %update how many elements have been accumulated so far
            z = ac-1;
    
            % multiply by the factor matrix entries
            i=1;
            for q=1:size(u,1) %<-- for each matrix in u
                % skip the unfolded mode
                if i==n
                    i = i+1;
                    continue
                end
    
                % multiply the factor and advance to the next
                t(z) = u{q}(idx(i), f) * t(z);
                i = i+1;
            end
        end
    end
    % accumulate m(:,f)
    for p=1:length(t)
        m(tind(p),f) = m(tind(p), f) + t(p);
    end
end
%return m;

end %<-- end function