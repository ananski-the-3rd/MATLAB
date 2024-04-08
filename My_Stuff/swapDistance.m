function dist = swapDistance(u, V)
%SWAPDISTANCE calculates the swap distance between two vectors
%
% dist = SWAPDISTANCE(u, V) calculates the minimum number of swaps required to
% get from row vector u to every row in V. V may be a vector or a 2D matrix.
%


if nargin < 2
    error('Not enough input arguments!')
end
if ~isrow(u)
    error('First input must be a row vector!')
end
n = length(u);
if size(V, 2) ~= n
    error('Inputs dimentions do not match!')
end
dist = inf(size(V, 1), 1);

is_possible = all(sort(u) == sort(V')', 2);
is_already_same = all(u == V, 2);
dist(is_already_same) = 0;
if all(~is_possible | is_already_same)
    return
end

for r = find(is_possible & ~is_already_same)'
    n_swaps = 0;
    not_done = true(1, n);
    while any(not_done)
        c = find(not_done, 1);
        i = find(u == V(r, c) & not_done, 1);
        while i ~= c
            not_done(i) = false;
            n_swaps = n_swaps + 1;
            i = find(u == V(r, i) & not_done, 1);
        end
        not_done(i) = false;
    end
    dist(r) = n_swaps;
end

end