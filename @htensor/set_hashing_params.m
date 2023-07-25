% Set hashing parameters
function t = set_hashing_params(t)
t.bits = ceil(log2(t.nbuckets));
t.sx = ceil(t.bits/8)-1;
t.sy = 4 * t.sx-1;
if t.sy < 1
    t.sy = 1;
end
t.sz = ceil(t.bits/2);
t.mask = t.nbuckets-1;
end
