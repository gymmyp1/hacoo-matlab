%Driver code for testing htensor(HaCOO) class

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

tic
t = read_htns('x.txt')
%t = read_htns('uber_trim.txt')
%t = read_htns('uber.txt')


get_tests(t)
display_tests(t)

toc

function get_tests(t)
    good = t.get([1 1 1]);
    bad = t.get([1 4 4]);

    if good ~= 0
        fprintf('Good index test successful..\n');
    else

        fprintf('Could not retrieve existing index.\n');
    end

    if bad == 0
        fprintf('Bad index test successful.\n');
    else
        fprinf("retrieved bad index\n");
    end
    

end

function display_tests(t)
    t.display_htns()
    t.all_indexes()
    t.all_vals()
end