function [B, zero_regions] = MineSweeper(siz, n)
% siz = 10;
% n = 12;

idx = 0;
while ~exist('siz', 'var') || ~isscalar(siz) || siz < 2 || (floor(siz) ~= siz) || siz > 100
    siz = input('Invalid board size. Board size must be a scalar between 2 and 100: ');
    idx = idx + 1;
    if idx > 2
        error('Invalid board size')
    end
end

if ~exist('n', 'var')
    n = round(siz^2/4);
end

if n > siz^2/2
    error('Too many mines')
end

Board = false(siz);
loc = randperm(siz^2, n);
Board(loc) = true;
A = [1,1,1;1,0,1;1,1,1];
B_check = padarray(Board, [1,1], true);
B_check = conv2(B_check, A, 'same');
B_8ts = B_check(2:end-1, 2:end-1) > 7;
while any(B_8ts, 'all')

loc = find(B_8ts & ~Board);
m = sum(B_8ts & Board, 'all') + length(loc);
idx = find(Board == 0);
Board(B_8ts & Board) = false;

trouble = ismember(loc, siz:siz:siz^2);
if any(trouble)
    loc(trouble) = loc(trouble)-2;
end
loc = loc + 1;
Board(loc) = false;
Board(idx(randperm(length(idx), m))) = true;
B_check = padarray(Board, [1,1], true);
B_check = conv2(B_check, A, 'same');
B_8ts = B_check(2:end-1, 2:end-1) > 7;


if sum(Board, 'all') > n % in case we double-counted a 8-neighboor mine
    idx = find(Board);
    Board(idx(randperm(length(idx), sum(Board, 'all')-n))) = 0;
end
end

B = conv2(Board, A, 'same');
B(Board) = nan;
B_check = B == 0;
zero_regions = labelmatrix(bwconncomp(B_check, 4));
B_im = B;
B_im(isnan(B_im)) = 8;
figure
subplot(1,2,1)
image(B_im, 'CDataMapping','scaled')
subplot(1,2,2)
image(zero_regions*(2^(8-max(zero_regions(:)))), 'CDataMapping', 'direct')


end