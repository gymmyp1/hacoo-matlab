%Driver code for testing HaCOO class
%working on this 8/26

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

tic
file = 'uber.txt';
%file = 'test.txt';
hashtable = readtable(file);
hashtable = table2array(hashtable);

idx = hashtable(:,1:end-1);
vals = hashtable(:,end);

summed_idx = cast(sum(idx,2),'int32');
summed_idx = summed_idx';

%initialize hacoo structure
nnz = length(summed_idx);
load_factor=0.6;
nbuckets = power(2,ceil(log2(nnz/load_factor)));
t = hacoo(nbuckets);
%t = hacoo();

% hash indexes for the hash keys
keys = arrayfun(@t.hash, summed_idx);

hashtable = cell(t.nbuckets,1);
%set everything in the table
prog = 0;
    for i = 1:nnz
        %t = t.set2(summed_idx(i),vals(i),keys(i));
        k = keys(i);
        v = vals(i);
        si = summed_idx(i);
        
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

%{
modes = 4;
fileID = 'uber.txt';
formatSpec = '%d %d';
sizeA = [modes+1 Inf];
fileID = fopen(fileID,'r');
data = fscanf(fileID,formatSpec,sizeA);
fclose(fileID);
%make sure to remove indexes with 0 values later...
data = data'


numRows = size(data,1);
numCols = size(data,2);

idx = data(:,1:numCols-1);
vals = data(:,end);

%concat the index
conc = arrayfun(@concaten, idx,'UniformOutput',false);
conc_idx = str2double(conc);

%may need to do some kind of check to make sure concatenated index is
%unique & using consistent # of bits

hash_keys = arrayfun(@hash, conc_idx);

  
%Create the tensor
nnz = height(idx);
load_factor=0.6;
nbuckets = power(2,ceil(log2(nnz/load_factor)));
t = hacoo(nbuckets);

prog = 0;
for i = 1:nnz
    t = t.set2(conc_idx(i),vals(i),hash_keys(i));
    prog = prog + 1;
    if mod(prog,10000) == 0
        prog
    end
end

t.max_chain_depth
%}


function t = read(file, m)
    modes = m;
    fileID = file;
    formatSpec = '%d %d';
    sizeA = [modes+1 Inf];
    fileID = fopen(fileID,'r');
    data = fscanf(fileID,formatSpec,sizeA);
    fclose(fileID);
    %make sure to remove indexes with 0 values later...
    data = data';
    numRows = size(data,1);
    numCols = size(data,2);

    idx = data(:,1:numCols-1);
    vals = data(:,end);
    
    %concat the index
    conc = arrayfun(@concaten, idx,'UniformOutput',false);
    conc_idx = str2double(conc);

    %may need to do some kind of check to make sure concatenated index is
    %unique & using consistent # of bits
    
    hash_keys = arrayfun(@hash, conc_idx);

      
    %Create the tensor
    nnz = height(idx);
    load_factor=0.6;
    nbuckets = power(2,ceil(log2(nnz/load_factor)));
    t = hacoo(nbuckets);

    prog = 0;
    for i = 1:nnz
        t = t.set2(conc_idx(i),vals(i),hash_keys(i));
        prog = prog + 1;
        if mod(prog,100000) == 0
            prog
        end
    end
end
