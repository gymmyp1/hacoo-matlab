%Time how long it takes to insert N elements

NNZ = 25000;

%create a matrix of nnz random indexes and values to insert with no duplicate
%indexes
vals = randi([1,9],nnz,1);

nrows = nnz;
ncols = nmodes;
maxvalue = 2500;
idx = zeros(nrows, ncols);
for whichrow = 1:nrows
    idx(whichrow, :) = randperm(maxvalue, ncols);
end

%concatenate the indexes
T = arrayfun(@string,idx);
X = strcat(T(:,1),'',T(:,2)); %To start the new array

for i=3:size(T,2)
    X= strcat(X(:,:),'',T(:,i));
end

concatIdx = arrayfun(@str2double,X);


fprintf("Inserting %d nonzeros.\n",NNZ);

fprintf("HaCOO:\n");
[tns,elapsed] = build(NNZ,"htensor",idx,vals,concatIdx);
fprintf("Elapsed time is %f seconds.\n",elapsed);

fprintf("COO:\n")
[tns,elapsed] = build(NNZ, "sptensor",idx,vals,concatIdx);
fprintf("Elapsed time is %f seconds.\n",elapsed);

%{
Insert tensor indexes one element at a time into a COO or HaCOO tensor.
    Parameters:
        nnz - number of nonzeros to insert
        format - the format of tensor you want to build (sptensor,htensor)
        idx - array of tensor indexes
        vals - array of tensor values
        concatIdx - array of concatenated indexes for HaCOO format (is
        ignored for COO format)
    Returns:
        tns - built HaCOO/COO tensor
%}
function [tns,elapsed] = build(nnz,format,idx,vals,concatIdx)

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
        tns = tns.set(idx(i,:),vals(i),'concatIdx',concatIdx(i));
    end
end
elapsed = toc;

end