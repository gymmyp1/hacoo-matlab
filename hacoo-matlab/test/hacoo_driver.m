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
t = hacoo(modes)
%t = hacoo.read(file)