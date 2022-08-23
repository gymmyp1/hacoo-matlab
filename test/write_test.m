%testing writing tensor to file in HaCOO format
addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab

t = read_tns('test.txt');

file = "test_hacoo.txt";
t.write_tns(file);

%{
function write_tns(t,file)
    %write tensor to a file in HaCoo fomat
    fprintf("Writing tensor...\n");
    fileID = fopen(file,'w');
    
    for i = 1:t.nbuckets
        for j = 1:length(t.table{i})
            if t.table{i}{j}.morton ~= -1
                fprintf(fileID,'%d %f %d\n',t.table{i}{j}.morton,t.table{i}{j}.value,i);
            end
        end
    end
    fclose(fileID);
end
%}

function t = read_tns(file)
    T = readtable(file);
    nnz = height(T);

    %Create the tensor
    t = hacoo(nnz);
    
    prog = 0;
    for row = 1:height(T)
        row = T(row,:);
        length = width(row);
        val = row.(length);
        idx = table2array(removevars(row,length)); %remove the value so the rest is the index
        
        t = t.set(idx,val);
        prog = prog + 1;
        if mod(prog,100000) == 0
            prog
        end
    end
end