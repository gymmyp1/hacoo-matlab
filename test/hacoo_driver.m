%Driver code for testing HaCOO class

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

t = read('test.txt');


t.display_tns()

function t = read(file)
    T = readtable(file);

    %Create the tensor
    t = hacoo();
    
    for row = 1:height(T)
        row = T(row,:);
        length = width(row);
        val = row.(length);
        idx = table2array(removevars(row,length)); %remove the value so the rest is the index
    
        t.set(idx,val);
    end
end