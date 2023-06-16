%testing which hashing scheme is fastest

[idx,vals] = extractCOO("uber.txt");
fprintf("finished extracting indexes\n");

fprintf("Timing Jenkins hashing...\n");
tic
%Jenkins one-at-at time
S = sum(idx,2);
shift1 = arrayfun(@(x) x + bitshift(x,2),S);
shift2 = arrayfun(@(x) bitxor(x, bitshift(x,-1)),shift1);
shift3 = arrayfun(@(x) x + bitshift(x,5),shift2);
keys =  arrayfun(@(x) mod(x,68719476736),shift3);
toc


fprintf("Timing Jenkins hashing w/ for loop...\n");
tic
%Jenkins one-at-at time
for i=1:length(idx)
    S = sum(idx(i,:));
    shift1 = S + bitshift(S,2);
    shift2 = bitxor(shift1, bitshift(shift1,-1));
    shift3 =  shift2 + bitshift(shift2,5);
    keys(i) = mod(shift3,68719476736);
end
toc

fprintf("Timing CRC hashing in for loop\n");

%fast CRC
tic
for i=1:length(idx)
    crc32(idx(i));
end
toc

function [idx,vals] = extractCOO(file)
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
end