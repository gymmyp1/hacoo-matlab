%trying to figure out how to concatenate indexes

file = 'uber.txt';

method1(file)
method2(file)

function method1(file)
fprintf("method 1\n")
tic

fprintf('extracting vals...\n');
%Get the first line using fgetl to figure out how many modes
opt = {'Delimiter',' '};
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));
if strcmp(file,"enron.txt") || strcmp(file,"nell-2.txt") || strcmp(file,"lbnl.txt")
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

vals = tdata(:,end);

fprintf("extracting indexes...\n");

lines = readlines(file,"EmptyLineRule","skip");

%get only the indexes
% Match a blank (\s) followed by zero or more non-blanks(\S*) up to the 
% end of the string. Matched stubstring is replaced by empty string ('').
idx = regexprep(lines,'\s\S*$','');
idx = strrep(idx,' ','');
idx = str2double(idx);


toc
end

function method2(file)
fprintf("method 2\n")
tic

%Get the first line using fgetl to figure out how many modes
opt = {'Delimiter',' '};
fid = fopen(file,'rt');
hdr = fgetl(fid);
num = numel(regexp(hdr,' ','split'));
if strcmp(file,"enron.txt") || strcmp(file,"nell-2.txt") || strcmp(file,"lbnl.txt")
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

T = arrayfun(@string,idx);

%apply to each row

X = strcat(T(:,1),'',T(:,2)); %To start the new array

for i=3:size(T,2)
    %fprintf("concatenating mode %d\n",i)
    X= strcat(X(:,:),'',T(:,i));
end

idx = arrayfun(@str2double,X);

toc
end