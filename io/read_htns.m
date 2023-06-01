% Read a COO text file into a HaCOO sparse tensor
% 
% Input:
%       file - text file, sparse tensor in COO format
% Returns:
%       t - HaCOO htensor containing nnz from the file
%
% Expects text file input of the format: 
%       idx_1, idx_2,...idx_n val

function t = read_htns(file)

%Get the first line using fgetl to figure out how many modes
opt = {'Delimiter',' '};
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));
if strcmp(file,"enron.txt") || strcmp(file,"nell-2.txt") || strcmp(file,"lbnl.txt")
    fmt = repmat('%d',1,num-1); %to read files with decimal values (enron, nell-2,lbnl)
    fmt = strcat(fmt,'%f');
else
    fmt = repmat('%d',1,num); %to read files with no decimal values
end

frewind(fid); %put first line back

sizeA = [num Inf];
tdata = fscanf(fid,fmt,sizeA);
tdata = tdata';

fclose(fid);

idx = tdata(:,1:num-1);
vals = tdata(:,end);

t = htensor(idx,vals);

end