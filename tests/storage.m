%Test how much storage table occupies

%empty cell
emptyCell = {};

%array of 2 empty cells
empty_1 = cell(2,1);

%single int in a matrix
oneInt = [2];

%multiple ints in a cell
multInt = [1 2 3 4];

%1 index entry in a cell
bucket = {multInt};

%multiple indexes in a cell
chainedBucket = {multInt;multInt};

fprintf("empty cell\n")
whos emptyCell
fprintf("array of 2 empty cells\n")
whos empty_1
fprintf("single int in a matrix\n")
whos oneInt
fprintf("multiple ints in a matrix\n")
whos multInt
whos bucket
whos chainedBucket