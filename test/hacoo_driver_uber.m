%Driver code for testing HaCOO class
%working on this 8/26

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

tic
%file = 'uber.txt';
file = 'test.txt';
hashtable = readtable(file);
hashtable = table2array(hashtable);

idx = hashtable(:,1:end-1);
vals = hashtable(:,end);

nmodes = size(idx,2);
format = '';
for d =1:nmodes
    format = strcat(format,'%i');
end

%Trying to figure out a way to concatenate indexes over each row...
%concat_idx = sscanf(sprintf(format,idx(1,:)),'%d')

concat_idx = rowfun(@cc_idx, idx)
concat_idx = concat_idx';

%initialize hacoo structure
nnz = length(concat_idx);
load_factor=0.6;
nbuckets = power(2,ceil(log2(nnz/load_factor)));
t = hacoo(nbuckets);
%t = hacoo();

% hash indexes for the hash keys
keys = arrayfun(@t.hash, concat_idx);

hashtable = cell(t.nbuckets,1);
%set everything in the table
prog = 0;
    for i = 1:nnz
        %t = t.set2(summed_idx(i),vals(i),keys(i));
        k = keys(i);
        v = vals(i);
        si = concat_idx(i);
        
         %check if any keys are equal to 0, due to matlab indexing
            if k < 1
                k = 1;
            end
            
    		% We already have the index and key, insert accordingly
            if v ~= 0
                hashtable{k}{end+1} = node(si, v);
                t.hash_curr_size = t.hash_curr_size + 1;
                depth = length(hashtable{k});
                if depth > t.max_chain_depth
	                t.max_chain_depth = depth;
                end
            else
                %remove entry in table
            end
        prog = prog + 1;
        if mod(prog,100000) == 0
            prog
        end
    end

toc


function r = cc_idx(idx)
    r = sscanf(sprintf('%i%i%i',idx),'%i');
end

function t = read(file, m)
   
end
