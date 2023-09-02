%{
Function to time how long it takes to build a COO tensor line by line
    Parameters:
        file - COO file to read
        nnz - number of nonzeros to read (since doing this for all nnz takes
        a LONG time
        format - the format of tensor you want to build (sptensor,htensor)
        idx - array of tensor indexes
        vals - array of tensor values
        concatIdx - array of concatenated indexes for HaCOO format (is
        ignored for COO format)
    Returns:
        tns - built HaCOO/COO tensor
        walltime - elapsed time to insert all elements into tensor
        cpu_time - cpu time to insert all elements into tensor
%}
function [walltime, cpu_time] = build_frostt(file,nnz, format,idx,vals,concatIdx)

walltime = 0;
cpu_time = 0;

%Check if tensor format is valid
if strcmp(format,"sptensor") || strcmp(format,"coo")
    fmtNum = 1;
    %Get the first line using fgetl to figure out how many modes
    fid = fopen(file,'rt');
    hdr = fgetl(fid);
    num = numel(regexp(hdr,' ','split'));
    tns = sptensor(ones(1,num-1));
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

%iterate over each idx and insert
for i=1:nnz
    tic
    tStart = cputime;

    %If using COO format
    if fmtNum == 1
        tns(idx(i,:)) = vals(i);
    elseif fmtNum == 2 %If using HaCOO format
        tns = tns.set(idx(i,:),vals(i),'concatIdx',concatIdx(i));
    end
    walltime = walltime + toc;
    tEnd = cputime - tStart;
    cpu_time = cpu_time + tEnd;
end