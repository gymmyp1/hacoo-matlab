%Driver code for testing HaCOO class

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

%{ 
fid = fopen('fgetl.m'); %to read line by line
tline = fgetl(fid);
while ischar(tline)
    disp(tline)
    tline = fgetl(fid);
end
fclose(fid);
%}

modes = [5,5,5];
i = [1,5,10]; % morton code should be 2211
v = 1;

t = hacoo(modes);
length(t.table)
m = morton_encode(i);

t = t.set(i,v); %maybe i have to set t = to the new table each time?

g = t.get(i)

%t.get(i)

%t.table{1}
%t.table(1,1) = 273489;
%t.table(1,2) = 1;
%t.table(1,2)
%t.set(t,i, v)

%t = hacoo.read(file)
