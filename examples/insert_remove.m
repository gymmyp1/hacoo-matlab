%Insert or remove nonzeros with a HaCOO tensor.

t = read_htns('x.txt');

t.display_htns

%insert new nonzeros
t = t.set([2 4 1], 2);
t = t.set([5 4 5], 5);

t.display_htns()

%remove nonzeros
t = t.remove([1 1 1]);
t = t.remove([2 1 1]);
t = t.remove([1 2 1]);

t.display_htns()
