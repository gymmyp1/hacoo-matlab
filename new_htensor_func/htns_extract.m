function res = htns_extract(t,subs)
%EXTRACT Extract value for a sptensor. 
%
%   EXTRACT(X,SUBS) returns a list of values.
%
%   See also SPTENSOR/SUBSREF.
%
%Tensor Toolbox for MATLAB: <a href="https://www.tensortoolbox.org">www.tensortoolbox.org</a>

%convert subs array to a table for faster operation
tsubs = array2table(subs);

%for each index, retrieve its corresponding value in the tensor
vals = rowfun(@t.extract_val,tsubs, 'SeparateInputs', false);
res = table2array(vals);



