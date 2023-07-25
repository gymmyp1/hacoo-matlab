%{
            Retrieve all indexes and vals from HaCOO sparse tensor
        Parameters:
            t - HaCOO htensor
        Returns:
            subs - array of all indexes in HaCOO tensor t
            vals - array of all values in HaCOO tensor t
%}

function [subs,vals] = all_subsVals(t)
nnz = t.table(t.nnzLoc);
A = vertcat(nnz{1:end,:});
subs = A(:,1:end-1);
vals = A(:,end);
end