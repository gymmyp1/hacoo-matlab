%Driver code for testing all_subs() and all_vals()

tic
t = read_htns('coo_ex.txt');

[subs,vals] = t.all_subsVals()
toc
