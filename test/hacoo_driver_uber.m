%Driver code for testing HaCOO class
%working on this 8/26

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

tic
file = 'uber.txt';
file = 'test.txt';
table = readtable(file);
table = table2array(table);

%initialize hacoo structure
t = hacoo();

vals = table(:,end);
idx = table(:,1:end-1);

summed_idx = cast(sum(idx,2),'int32')
summed_idx = summed_idx'

% hash the indexes, append new column to table?
key = arrayfun(@t.hash, summed_idx)
%apply operation across all rows

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


function n = concaten(row) 
    n = strcat(num2str(row));
    n = str2num(n);
end

function k = hash(t,i)
            %{
		Hash the index and return the morton code and key.

		Parameters:
            i - sparse tensor index as the summed index

		Returns:
			key
            %}
            hash = i;
            hash = hash + (bitshift(hash,t.sx)); %bit shift to the left
            hash = bitxor(hash, bitshift(hash,-t.sy)); %bit shift to the right
            hash = hash + (bitshift(hash,t.sz)); %bit shift to the left
            k = mod(hash,t.nbuckets);
end

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
