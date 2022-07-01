%Test for morton endoding/decoding functions

addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/hacoo/

vals = [uint64(1),uint64(5),uint64(10)] %morton code should be 2211
m = encode(vals)
l = decode(m, 3)
