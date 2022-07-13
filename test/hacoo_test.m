%Tests for implementation for HaCOO class

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

modes = [5,5,5];
i = [1,5,10]; % morton code should be 2211
v = 1;

t = hacoo(modes);
length(t.table)
m = morton_encode(i);

t = t.set(i,v); %maybe i have to set t = to the new table each time?

%g = t.get(i)