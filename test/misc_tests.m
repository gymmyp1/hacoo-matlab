%Tests to speed up set, retrieve, and read functions.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

file = 'uber_trim.txt';

%Get the first line w/ fgetl to figure out how many modes
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


%t = htensor(idx,vals);

%Sum every row
S = sum(idx,2);
%Make a copy of the original
hash = S;

small = [1; 394; 1029; 123];
shift1 = arrayfun(@(x) x + bitshift(x,t.sx),small);
shift2 = arrayfun(@(x) bitxor(x, bitshift(x,-t.sy)),shift1);
shift3 = arrayfun(@(x) x + bitshift(x,t.sz),shift2);
k =  arrayfun(@(x) mod(x,t.nbuckets),shift3)

other = arrayfun(@hash_fun, small)
% hash indexes for the hash keys
%keys = arrayfun(@t.hash, summed_idx);
%keys = keys';

function k = hash_fun (m)
%Hashing algorithm
sx =2;
sy = 7;
sz=9;
t.nbuckets = 262144;
hash = m;
hash = hash + (bitshift(hash,sx)); %bit shift to the left
hash = bitxor(hash, bitshift(hash,-sy)); %bit shift to the right
hash = hash + (bitshift(hash,sz)); %bit shift to the left
k = mod(hash,t.nbuckets);
end
