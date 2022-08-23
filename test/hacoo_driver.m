%Driver code for testing HaCOO class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

t = read('test.txt',3);
%t.get([3, 5, 5])
t.display_tns();



tic
t = read('uber.txt',4);
t.max_chain_depth
toc


%file = "uber_hacoo.txt";
%t.write_tns(file);

function n = concaten(i) 
    n = strcat(num2str(i));
end

function k = hash(i)
            %{
		Hash the index and return the morton code and key.

		Parameters:
            i - sparse tensor index as the concatenated index

		Returns:
			key
            %}
            hash = i;
            hash = hash + (bitshift(hash,6)); %bit shift to the left
            hash = bitxor(hash, bitshift(hash,-5)); %bit shift to the right
            hash = hash + (bitshift(hash,2)); %bit shift to the left
            k = mod(hash,128);
end

function t = read(file, m)
    modes = m;
    fileID = file;
    formatSpec = '%d %f';
    sizeA = [modes+1 Inf];
    fileID = fopen(fileID,'r');
    data = fscanf(fileID,formatSpec,sizeA);
    fclose(fileID);
    %make sure to remove indexes with 0 values later...
    data = data';
    vals = data(:,end);
    
    numRows = size(data,1);
    numCols = size(data,2);
    idx = data(:,1:numCols-1);
    
    %concat the index
    conc = arrayfun(@concaten, idx,'UniformOutput',false);
    R = str2double(conc);
    %may need to do some kind of check to make sure concatenated index is
    %unique & using consistent # of bits
    
    hash_keys = arrayfun(@hash, R);

      
    %Create the tensor
    nnz = height(idx);
    if nnz > 512
        t = hacoo(nnz);
    else
        t = hacoo(512);
    end

    prog = 0;
    for i = 1:nnz
        t = t.set2(R(i),vals(i),hash_keys(i));
        prog = prog + 1;
        if mod(prog,100000) == 0
            prog
        end
    end
end
