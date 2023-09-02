%{
Script: produce_frostt_res

Description: Reproduce Figure 12, reports average time over N trials (10 
by default) to calculate MTTKRP over all modes for both COO Tensor Toolbox
sparse tensors and HaCOO htensor sparse tensors.
%}

%

files = ["shuf_uber.txt" "shuf_chicago.txt" "shuf_enron.txt" "shuf_nell-2.txt" "shuf_enron.txt"];
NUMTRIALS = 10;

% List of number of tensor elements to insert
nnzList = [100000];

for f=1:length(files)
    %Get the first line using fgetl to figure out how many modes
    file = files(f)
    [IDX,VALS] = extract_idx(file);

    %create concatenated indexes list
    CONCATIDX = concatenateIndexes(IDX);

    for i=1:length(nnzList)
        NNZ = nnzList(i)

        %trim idx, vals, and concatIdx list
        idx = IDX(1:NNZ,:);
        vals = VALS(1:NNZ);
        concatIdx = CONCATIDX(1:NNZ);

        outFileName = strcat(string(NNZ),"frostt_build_",file);
        outFile = fopen(outFileName,'w');

        htns_elapsed = 0;
        htns_cpu = 0;

        fprintf(outFile,"Reading first %d nonzeros.\n",NNZ);
        fprintf(outFile,"Averages calculated over %d trials.\n",NUMTRIALS);

        fprintf("HaCOO times:\n");
        for n=1:NUMTRIALS
            fprintf("Trial number: %d\n",n);
            [walltime,cpu_time] = build_frostt(file,NNZ,"htensor",idx,vals,concatIdx);
            htns_elapsed = htns_elapsed + walltime;
            htns_cpu = htns_cpu + cpu_time;
        end

        htns_elapsed = htns_elapsed/NUMTRIALS;
        htns_cpu = htns_cpu/NUMTRIALS;
        fprintf(outFile,"Average elapsed time using HaCOO: %f\n",htns_elapsed);
        fprintf(outFile,"Average CPU time using HaCOO: %f\n",htns_cpu);

        fprintf("COO times:\n")
        tt_elapsed = 0;
        tt_cpu = 0;
        concatIdx = 0; %this var is not used for COO
        for n=1:NUMTRIALS
            fprintf("Trial number: %d\n",n);
            [walltime,cpu_time] = build_frostt(file,NNZ, "sptensor",idx,vals,concatIdx);
            tt_elapsed = tt_elapsed + walltime;
            tt_cpu = tt_cpu + cpu_time;
        end


        tt_elapsed= tt_elapsed/NUMTRIALS;
        tt_cpu = tt_cpu/NUMTRIALS;

        fprintf(outFile,"Average elapsed time using Tensor Toolbox: %f\n",tt_elapsed);
        fprintf(outFile,"Average CPU time using Tensor Toolbox: %f\n",tt_cpu);

    end
end

function [idx,vals] = extract_idx(file)
%Get the first line using fgetl to figure out how many modes
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));

if strcmp(file,"shuf_enron.txt") || strcmp(file,"shuf_nell-2.txt") || strcmp(file,"shuf_lbnl.txt")
    fmt = repmat('%d',1,num-1); %to read files with decimal values (enron, nell-2,lbnl)
    fmt = strcat(fmt,'%f');
else
    fmt = repmat('%d',1,num); %to read files with no decimal values
end

frewind(fid); %put first line back
sizeA = [num Inf];
%sizeA = [num nnz]; %for larger tensors limit the number of nnz to read
tdata = fscanf(fid,fmt,sizeA);
tdata = tdata';
fclose(fid);

idx = tdata(:,1:num-1);
vals = tdata(:,end);
end