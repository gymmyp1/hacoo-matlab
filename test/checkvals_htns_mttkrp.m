%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

file = 'x.txt';
T = read_tns(file); %<--the tensor

N = T.nmodes;
Uinit = cell(N,1);
for n = dimorder(2:end)
    Uinit{n} = rand(htns_size(T,n),R);
end

u = Uinit;

% number of columns
fmax = size(u,2);
    
% create the result array
m = zeros(T.modes(n), fmax);
    
% go through each column
for f=1:fmax
    % accumulation arrays
    z=1;
    t=[];
    tind=[];
    
    % go through every non-zero
    for k=1:T.nbuckets
        if isempty(T.table{k})
            continue
        end
        for j=1:length(T.table{k})  %<-- loop over each entry in that bucket
            idx = T.table{k}{j}.idx_id;
            t(end+1) = T.table{k}{j}.value;
            tind(end+1) = idx(n);
            z = length(t);
    
            % multiply by the factor matrix entries
            i=1;
            for q=1:size(u,2) %<-- for each matrix in u
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