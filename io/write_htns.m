%{ 
  Write a HaCOO sparse tensor to a file.
  Stored data:
    table
    nbuckets
    modes
    hash_curr_size
    max_chain_depth
    load factor
  
% Input:
%       t - a HaCOO htensor
%       file - text file string to write to, file name must end in '.mat'
%}

function write_htns(t,file)
    T = t.table;
    
    %Save extra info
    M = cell(5,1);
    M{1} = t.nbuckets;
    M{2} = t.modes;
    M{3} = t.hash_curr_size;
    M{4} = t.max_chain_depth;
    M{5} = t.load_factor;
    
    save(file,'T','M','-v7.3'); %adding version to save large files
end