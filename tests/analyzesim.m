%test max chain depth for hash function


file = "enron.txt";
newStr = erase(file,".txt");
file = strcat(newStr,'_sim_mat.txt');

T = readtable(file);

% create the counts array
counts = zeros(nbuckets,1);
collisions = 0;
indexes = T.Var1;
entries = length(T.Var2);
for i=2:entries
    index = T.Var2(i);
    counts(index) = 1 + counts(index);
    if counts(index) > 1
        collisions = collisions + 1;
    end
end

% compute the collision percent
colrate = collisions / entries * 100;
max_probe = max(counts);

fprintf("Collision rate: %f\n",colrate);
fprintf("Max probe depth: %d\n",max_probe);