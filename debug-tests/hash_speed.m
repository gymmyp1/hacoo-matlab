%testing which hashing scheme is fastest

file = "uber.txt";
lines = readlines(file,"EmptyLineRule","skip");

%get only the indexes
% Match a blank (\s) followed by zero or more non-blanks(\S*) up to the 
% end of the string. Matched stubstring is replaced by empty string ('').
idx = regexprep(lines,'\s\S*$','');
idx = strrep(idx,' ','');
idx = str2double(idx);
fprintf("finished extracting indexes\n");

function jenkins(idx)
fprintf("Timing Jenkins hashing...\n");
tic
%Jenkins one-at-at time

shift1 = arrayfun(@(x) x + bitshift(x,2),S);
shift2 = arrayfun(@(x) bitxor(x, bitshift(x,-1)),shift1);
shift3 = arrayfun(@(x) x + bitshift(x,5),shift2);
keys =  arrayfun(@(x) mod(x,68719476736),shift3);
toc
end

function jenkins2(idx)
fprintf("Timing Jenkins hashing w/ for loop...\n");
keys = zeros(1,length(idx));

tic
%Jenkins one-at-at time
for i=1:length(idx)
    shift1 = idx(i) + bitshift(idx(i),2);
    shift2 = bitxor(shift1, bitshift(shift1,-1));
    shift3 =  shift2 + bitshift(shift2,5);
    keys(i) = mod(shift3,68719476736);
end
toc
end

function test_crc(idx)

fprintf("Timing CRC hashing in for loop\n");
%fast CRC
tic
for i=1:length(idx)
    crc32(idx(i));
end
toc

end