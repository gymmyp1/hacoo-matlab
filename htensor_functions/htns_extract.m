function res = htns_extract(t,subs)
%EXTRACT Extract values corresponding to list of subs
% for a HaCOO htensor
%
%convert subs array to a table for faster operation
tsubs = array2table(subs);

%for each index, retrieve its corresponding value in the tensor
vals = rowfun(@t.extract_val,tsubs, 'SeparateInputs', false);
res = table2array(vals);



