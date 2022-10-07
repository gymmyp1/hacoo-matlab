% Function testing for retrieving tensor slices.

addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
%addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

t = read_htns(file);

r1 = htns_getslice(t,'[:,:,5]');
r2 = htns_getslice(t,'[:,1,:]');

%r.display_htns();
r2.display_htns()