%Time how long it takes to insert N elements

nnz = 25000;
nmodes = 3;

%create a matrix of nnz random indexes and values to insert with no duplicate indexes
vals = randi([1,9],nnz,1);

nrows = nnz;
ncols = nmodes;
maxvalue = 25000;
idx = zeros(nrows, ncols);
for whichrow = 1:nrows
    idx(whichrow, :) = randperm(maxvalue, ncols);
end

fprintf("Inserting %d nonzeros.\n",NNZ);

fprintf("HaCOO:\n");
[H,elapsed] = build(NNZ,"htensor",idx,vals);
fprintf("Elapsed time is %f seconds.\n",elapsed);

fprintf("COO:\n")
[S,elapsed] = build(NNZ, "sptensor",idx,vals);
fprintf("Elapsed time is %f seconds.\n",elapsed);

%{
Insert tensor indexes one element at a time into a COO or HaCOO tensor.
    Parameters:
        nnz - number of nonzeros to insert
        format - the format of tensor you want to build (sptensor,htensor)
        idx - array of tensor indexes
        vals - array of tensor values
    Returns:
        tns - built HaCOO/COO tensor
%}
function [tns,elapsed] = build(nnz,format,idx,vals)

%Check if tensor format is valid
if strcmp(format,"sptensor") || strcmp(format,"coo")
    fmtNum = 1;
    tns = sptensor();
elseif strcmp(format,"htensor") || strcmp(format,"hacoo")
    fmtNum = 2;
    load_factor = 0.6;
    %calculate number of nonzeros needed
    NBUCKETS = power(2,ceil(log2(nnz/load_factor)));
    tns = htensor(NBUCKETS);
else
    fprintf("Tensor format invalid.\n");
    return
end

tic
%iterate over each idx and insert
for i=1:nnz
    %If using COO format
    if fmtNum == 1
        tns(idx(i,:)) = vals(i);
    elseif fmtNum == 2 %If using HaCOO format
        tns = tns.set(idx(i,:),vals(i));
    end
end
elapsed = toc;

end