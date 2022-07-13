T = readtable('test/test.txt');

for row = 1:height(T)
    %To access a row in the table, use T(row,:)
    row = T(row,:);
    length = width(row);
    v = row.(length);
    index = table2array(removevars(row,length)); %remove the value so the rest is the index
end