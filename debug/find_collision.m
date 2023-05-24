%find which buckets have hash collisions
%returns array idx of buckets which have more than 1 entry

function idx = find_collision(t)

idx = [];

for i=1:t.nbuckets
    if size(t.table{i},1) > 1
        idx(end+1)=i;
    end
end


end