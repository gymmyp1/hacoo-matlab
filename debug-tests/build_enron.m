%build enron HaCOO tensor

file = "enron.txt";
newStr = erase(file,".txt");
outFileName= strcat(newStr,'hacoo.mat');

tic
[idx,vals] = extractIdx(file);

HASH_RATIO=0.6;
% Init hashing parameters
reqSize = length(idx) / HASH_RATIO;
e = ceil(log2(reqSize));
nbuckets = max(512, pow2(e));

fprintf("nbuckets: %d\n",nbuckets)
fprintf("bits: %d\n",bits)
fprintf("sx: %d\n",sx)
fprintf("sy: %d\n",sy)
fprintf("sz: %d\n",sz)
fprintf("elements to insert: %d\n",length(idx));

%create tensor with specified num of buckets
t = htensor(nbuckets); 
tic
t = t.set_bulk(idx,vals)
toc
%save(matfile,'t','-v7.3'); %adding version to save large files
toc

tic 
table = t.table;
%save(file,'table','-v7.3'); %save table

function [idx,vals] = extractIdx(file)
%Get the first line using fgetl to figure out how many modes
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));
if strcmp(file,"enron.txt") || strcmp(file,"nell.txt") || strcmp(file,"lbnl.txt") || strcmp(file,"nell-2.txt") || strcmp(file,"lbnl-network.txt")
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
end