function randarray = randw(range, dist, siz)
arguments
    range (1, :) = 1:100
    dist (1, :) = ones(length(range))
    siz (1, :) = [1, 1]
end
if length(dist) ~= length(range)
    error('Input arguments must be of the same length');
end
if length(siz) == 1
    siz = [siz siz];
end

dist = cumsum(dist./sum(dist, 2), 2);
randarray = zeros(siz);

for ii = 1:prod(siz)
randarray(ii) = range(find(dist >= rand, 1));
end