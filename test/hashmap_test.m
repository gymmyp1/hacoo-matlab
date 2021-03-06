% HaCOO hash table tests using MATLAB Map Object

import containers.Map

keys = [1280, 54, 9];
vals = [1, 1, 5];

newMap = containers.Map(keys,vals); %<-- Construct Initialized Map Object

%bit shift
%c = bitshift(a,k); %<-- positive k val shifts a in to the right, neg k shifts in on the left