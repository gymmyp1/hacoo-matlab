%file to test htns_extract function

file = 'x.txt';
%file = 'uber_trim.txt';
T = read_htns(file);

%subset of indexes to extract
subs = [1 1 1; 1 3 1];

M = htns_extract(T,subs);
disp(M);