%Read a sparse tensor in HaCOO file format:
%
%Format: morton_id value hash_key 
% (subsequent entries w/ same hash key belong in corresponding order in the
% chain)

tic
file = 'uber_hacoo.txt';
t = read_hacoo(file);
%t.display_tns();
toc

function t = read_hacoo(file)
    T = readtable(file);
    nnz = height(T);

    %Create the tensor
    t = hacoo(nnz);
    
    prog = 0;
    for row = 1:height(T)
        row = T(row,:);
        length = width(row);
        bucket = row.(length);
        t.table{bucket}{end+1} = node(row.(1), row.(2));
        prog = prog + 1;
        if mod(prog,100000) == 0
            prog
        end
    end
end