%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%"working" mttkrp... need to copy to hacoo file and check correctness

modes = 3;

a = [1 3 5; 2 4 6];
b = [1 4 7; 2 5 8; 3 6 9];
c = [1 2 3; 4 5 6];
u = cell(1,modes);
u{1} = a;
u{2} = b;
u{3} = c;

idx =  [0,0,0;
        0,1,0;
        0,2,0;
        1,0,0;
        1,1,0;
        1,2,0;
        0,0,1;
        0,1,1;
        0,2,1;
        1,0,1;
        1,1,1;
        1,2,1];

idx = idx+1;

vals = [1;2;3;4;5;6;7;8;9;10;11;12];
T = hacoo(idx,vals); %<--the tensor

n = 1;

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
	        %idx = morton_decode(T.table{k}{j}.morton, T.nmodes)
            idx = T.table{k}{j}.morton;
	        t(end+1) = T.table{k}{j}.value;
	        tind(end+1) = idx(n);
	        %z = length(t)-1
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

disp(m);

