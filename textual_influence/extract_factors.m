%{
 Part of Lowe's Textual Influence model.
% Script to extract factors from all document tensors in the current directory.
% Input:
%   nfactors - number of factors to use for decomposition
% Output:
%   F - list of factors
%   V - List of norms
%}

function [F,V] = extract_factors(nfactors)
%Get the first line using fgetl to figure out how many modes
opt = {'Delimiter',' '};
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));
if strcmp(file,"enron.txt") || strcmp(file,"nell-2.txt") || strcmp(file,"lbnl.txt") || strcmp(file,"shuf_enron.txt") || strcmp(file,"shuf_nell-2.txt") || strcmp(file,"shuf_lbnl.txt")
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

t = sptensor(idx,vals);

end