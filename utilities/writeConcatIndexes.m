%Read COO file, save new file with concatenated indexes

function writeConcatIndexes(file)

%Get the first line using fgetl to figure out how many modes
%opt = {'Delimiter',' '};
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));
if strcmp(file,"enron.txt") || strcmp(file,"nell.txt") || strcmp(file,"lbnl.txt")
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

%write matrix to file
e = erase(file,'.txt'); %erase .txt ending
newFileName = strcat(e,'_concat.txt');
writematrix(concatIdx,newFileName);

end