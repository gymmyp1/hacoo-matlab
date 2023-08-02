%trying to figure out what method of concatenating indexes is fastest

file = 'uber.txt';

%method1(file)
%method2(file)
method3(file)

function method3(file)
tic
idx = extractIndexes(file);
nmodes = size(idx,2);
rows = length(idx);
%multipliers
a = flip(0:nmodes-1,2);
b = repmat(10,1,nmodes);
m = b.^a;

concatIdx = zeros(rows,1);

for i=1:rows
    concatIdx(i) = sum(idx(i,:).*m); %elementwise multipication
end
toc
end

function method1(file)
fprintf("method 1\n")
tic

%Get the first line using fgetl to figure out how many modes
%sizeA = [num Inf];
%tdata = fscanf(fid,fmt,sizeA);
%tdata = tdata';

%fclose(fid);


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
[idx] = extractIndexes(file);

T = arrayfun(@string,idx);

%apply to each row

X = strcat(T(:,1),'',T(:,2)); %To start the new array

for i=3:size(T,2)
    %fprintf("concatenating mode %d\n",i)
    X= strcat(X(:,:),'',T(:,i));
end

concatIdx = arrayfun(@str2double,X)

toc
end