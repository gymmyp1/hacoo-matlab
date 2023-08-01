%time how long it takes to insert n elements in a HaCOO/COO sptensor.

n = 25000;
nmodes = 4;

%create HaCOO tensor
t = htensor(n);

%create COO sptensor
s = sptensor();

%create a matrix of n random indexes and values to insert with no duplicate
%indexes
vals = randi([1,9],n,1);

nrows = n;
ncols = nmodes;
maxvalue = 2500;
idx = zeros(nrows, ncols);
for whichrow = 1:nrows
    idx(whichrow, :) = randperm(maxvalue, ncols);
end


%time insertion for HaCOO
tic
for i=1:length(idx)
    t = t.set(idx(i,:),vals(i));
end
toc

%time insertion for COO
tic
for i=1:length(idx)
    s(idx(i,:)) = vals(i);
end
toc