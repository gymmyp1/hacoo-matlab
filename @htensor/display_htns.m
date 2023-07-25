% Print all nonzero elements.
function display_htns(t)
t.hash_curr_size
print_limit = 100;

if (t.hash_curr_size > print_limit)
    prompt = "The HaCOO tensor you are about to print contains more than 100 elements. Do you want to print? (Y/N): ";
    p = input(prompt,"s");
    if p  ~= "Y" || p ~= "y"
        return
    end
else
    %just print
    fprintf("Printing %d tensor elements.\n",t.hash_curr_size);
    nnz = t.table(t.nnzLoc);
    A = vertcat(nnz{1:end,:});
    disp(A)
end
end
