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

modes = [1,5,10];
i = [2,1,1];
v = 1;

t = hacoo(modes);

t.search(512)

t.table{1}.morton = 512
t.search(512)

%t.table{1}
%t.table(1,1) = 273489;
%t.table(1,2) = 1;
%t.table(1,2)
%t.set(t,i, v)

%t = hacoo.read(file)
