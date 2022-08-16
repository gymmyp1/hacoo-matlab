%Driver code for testing HaCOO class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

%t = read('test.txt');
%t.get([3, 5, 5])
%t.display_tns();

t = read('uber.txt');
t.max_chain_depth

function t = read(file)
    T = readtable(file);
    nnz = height(T);

    %Create the tensor
    t = hacoo(nnz);
    
    for row = 1:height(T)
        row = T(row,:);
        length = width(row);
        val = row.(length);
        idx = table2array(removevars(row,length)); %remove the value so the rest is the index
        
        t = t.set(idx,val);
    end
end