% Read a COO text file into a HaCOO sparse tensor
%
% Input:
%       file - text file sparse tensor in COO format
%       OR
%       file - text file sparse tensor in COO format
%       concatIdxFile - file containing concatenated indexes for the same COO file, to save time.
% Returns:
%       t - HaCOO htensor containing nnz from the file
%
% Expects text file input of the format:
%       idx_1, idx_2,...idx_n val

function t = read_htns(varargin)

file = varargin{1};

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

switch nargin
    case 1

        lines = readlines(file,"EmptyLineRule","skip");

        %get only the indexes
        % Match a blank (\s) followed by zero or more non-blanks(\S*) up to the
        % end of the string. Matched stubstring is replaced by empty string ('').
        concatIdx = regexprep(lines,'\s\S*$','');
        concatIdx = strrep(concatIdx,' ','');
        concatIdx = str2double(concatIdx);

        t = htensor(idx,vals,concatIdx);

    case 2
        concatIdxFile = varargin{2};
        concatIdx = readmatrix(concatIdxFile);
        t = htensor(idx,vals,concatIdx);
    otherwise
        fprintf("Incorrect number of arguments.\n");

end