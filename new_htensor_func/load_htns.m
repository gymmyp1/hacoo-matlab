%{
  Load a .mat file into a HaCOO sparse tensor
% 
% Input:
%       file - .mat file created from HaCOO's save function.
% Returns:
%       t - HaCOO htensor
%
% Expects .mat file input of the format: 
%       A: Indexes, or subs
%       B: Values
%       C: Chain depths
%       D: modes,hash curr size, laod factor 
%}

function t = load_htns(file)
    t = htensor(file); %calls constructor case 1
end