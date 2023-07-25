%{
        Rehash existing entries in tensor to a new tensor of double the
        existing size.
        
        Parameters:
               t - HaCOO tensor
        Returns:
               r - new HaCOO tensor with rehashed entries
%}
function new = rehash(t)
%gather all existing subscripts and vals into arrays
[subs,vals] = all_subsVals(t);

%Create new tensor, constructor will fill new values into table
new = htensor(subs,vals); %!! this takes a while, since we don't have a fast way to concatenate indexes yet.

end