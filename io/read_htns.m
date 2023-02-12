% Read a text file into a HaCOO sparse tensor
% 
% Input:
%       file - text file string
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
fmt = repmat('%d',1,num);
sizeA = [num Inf];
tdata = fscanf(fid,fmt,sizeA);
tdata = tdata';

fclose(fid);

idx = tdata(:,1:num-1);
vals = tdata(:,end);

t = htensor(idx,vals);

end