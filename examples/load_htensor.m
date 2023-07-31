%{
Save and load a .mat HaCOO tensor.
%}

% create a HaCOO tensor with 3 nonzeros.
idx = [1 1 1;
       1 2 0;
       2 1 0];

vals = [1, 2, 5];

x = htensor(idx,vals)

%specify new file name
filename = "x_hacoo.mat";

%save tensor x to .mat file
write_htns(x,filename);

%load the tensor into workspace
l = load_htns(filename)