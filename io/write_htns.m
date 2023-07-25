%{
Write a HaCOO sparse tensor to a file.
  
Input:
       t - a HaCOO htensor
       file - text file string to write to, file name must end in '.mat'
%}

function write_htns(t,file)
    save(file,'t','-v7.3'); %adding version to save large files
end