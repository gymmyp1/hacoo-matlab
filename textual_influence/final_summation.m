%{
 After factors have been matched, final output of the model can be
 summarized by summing the influence of each source document & author
 contribution factor.

 Document numbers: 
 1. Lin
 2. Schlapbach
 3. Gazzah
 4. Manabe
 5. Kolda
 6. Blei
 7. Serfas (target)
%}
function [I,author] = final_summation(ndocs,S,W)

%I = list of 0 repeated ndocs - 1 times
I = zeros(1, ndocs-1);

%list of document authors


for i=1:ndocs
    if S(i) == 0
        author = author + W(i);
    else
        %j = document number corresponding with S(i)
        I(i) = I(i) + W(i);
    end
end

end

