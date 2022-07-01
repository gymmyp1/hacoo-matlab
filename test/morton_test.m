%Test for morton endoding/decoding functions

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/morton/

vals = [uint64(1),uint64(5),uint64(10)] %morton code should be 2211
m = morton_encode(vals)
l = morton_decode(m, 3)
