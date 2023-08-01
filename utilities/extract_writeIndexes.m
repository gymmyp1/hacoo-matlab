%{
Extract indexes from a COO text file & write the matrix to a .txt file.
Parameters:
    file - .txt file of COO indexes
    fileOut - .txt file to write indexes to
Returns:
    idx - array of tensor indexes
%}

function idx = extract_writeIndexes(varargin)

file = varargin{1};
fileOut = varargin{2};

%Get the first line using fgetl to figure out how many modes
%opt = {'Delimiter',' '};
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

writematrix(idx,fileOut);

end
