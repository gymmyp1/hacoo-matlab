%test max chain depth for hash function

file = "enron.txt";
newStr = erase(file,".txt");
outFileName= strcat(newStr,'_sim_mat.txt');


[idx,vals,concatIdx] = extractIdx(file);

HASH_RATIO=0.6;
% Init hashing parameters
reqSize = length(idx) / HASH_RATIO;
e = ceil(log2(reqSize));
nbuckets = max(512, pow2(e))

bits = ceil(log2(nbuckets));
sx = ceil(bits/8)-1;
sy = 4 * sx-1;
if sy < 1
    sy = 1;
end
sz = ceil(bits/2);
mask = nbuckets-1;

fprintf("bits: %d\n",bits)
fprintf("sx: %d\n",sx)
fprintf("sy: %d\n",sy)
fprintf("sz: %d\n",sz)

outFile = fopen(outFileName,'w');
fprintf(outFile,"nbuckets %d\n",nbuckets);

for i=1:length(idx)
    [m,k] = hash(concatIdx(i),sx,sy,sz,nbuckets);
    fprintf(outFile,"%d %d\n",m,k);
end

function [m,k] = hash(concatIdx,sx,sy,sz,nbuckets)
m = concatIdx;
hash = concatIdx;
hash = hash + bitshift(hash,sx);
hash = bitxor(hash, bitshift(hash,-sy));
hash = hash + bitshift(hash,sz);
k = mod(hash,nbuckets);
if k == 0
    k = 1;
end
end


function [idx,vals,concatIdx] = extractIdx(file)
%Get the first line using fgetl to figure out how many modes
opt = {'Delimiter',' '};
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


lines = readlines(file,"EmptyLineRule","skip");

%get only the indexes
% Match a blank (\s) followed by zero or more non-blanks(\S*) up to the
% end of the string. Matched stubstring is replaced by empty string ('').
concatIdx = regexprep(lines,'\s\S*$','');
concatIdx = strrep(concatIdx,' ','');
concatIdx = str2double(concatIdx);

end