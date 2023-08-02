function concatIdx = concatenateIndexes(idx)

nmodes = size(idx,2);
rows = length(idx);

%set up multipliers
a = flip(0:nmodes-1,2);
b = repmat(10,1,nmodes);
m = b.^a;

concatIdx = zeros(rows,1);

for i=1:rows
    concatIdx(i) = sum(idx(i,:).*m); %elementwise multipication
end
end