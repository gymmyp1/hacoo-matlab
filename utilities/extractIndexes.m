%{
Extract indexes, values, and concatenated indexes from a COO text file.
Parameters:
    file - .txt file of COO indexes
Optionally:
    valueType - 1 if value type is a decimal (ex. enron, nell-2, lbnl tensors).
Returns:
    idx - array of tensor indexes
    vals - array of tensor values
    concatIdx - array of concatenated indexes
%}

function [idx,vals,concatIdx] = extractIndexes(varargin)

file = varargin{1};

%Get the first line using fgetl to figure out how many modes
%opt = {'Delimiter',' '};
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));

switch nargin
    case 1
        if strcmp(file,"enron.txt") || strcmp(file,"nell.txt") || strcmp(file,"lbnl.txt") || strcmp(file,"nell-2.txt") || strcmp(file,"lbnl-network.txt")
            fmt = repmat('%d',1,num-1); %to read files with decimal values (enron, nell-2,lbnl)
            fmt = strcat(fmt,'%f');
        else
            fmt = repmat('%d',1,num); %to read files with no decimal values
        end
    case 2
        %Should only use this if the value type is a decimal
        valueTypeDecimal = varargin{2};
        if valueTypeDecimal
            fmt = repmat('%d',1,num-1); %to read files with decimal values (enron, nell-2,lbnl)
            fmt = strcat(fmt,'%f');
        end

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
