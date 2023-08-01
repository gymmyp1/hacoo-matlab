%{ 
Creating a HaCOO sparse tensor

A HaCOO sparse tensor can be created by passing in a list of subscripts 
and values. For example, here we pass in three subscripts and a scalar 
value. The resuling sparse tensor has three nonzero entries, and the size 
is the size of the largest subscript in each dimension.
%}

idx = [1 1 1;
       1 2 0;
       2 1 0];

vals = [1, 2, 5];

x = htensor(idx,vals);

% A HaCOO sparse tensor also can be created from a COO format text file.
y = read_htns("y.txt");

% create an empty HaCOO tensor with default number of buckets (512)
e = htensor();

% create an empty HaCOO tensor with a specified number of buckets (should
% be a power of 2)
e2 = htensor(8);




%extract all nonzeros using all_subsVals()
[s,v] = all_subsVals(x);

%print all nonzeros
x.display_htns;