function u = counts(v)
l = length(v);
u = zeros(1, l);
for i = 1:l
    if u(i)
        continue
    end
    locs = false(1, l);
    for j = i:l
        if v(j) == v(i)
            locs(j) = true;
        end
    end
    u(locs) = sum(locs);
end

end