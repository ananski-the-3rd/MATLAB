function sol = sudoku(B)
%SUDOKU solves a sudoku given by board B. also shows solution step by step
%graphically. If B is a vector, SUDOKU will try to rearrange B into a
%sudoku board, row by row.
% B = [0,6,0,0,0,0,0,1,0,0,5,0,0,3,0,0,7,0,0,2,0,5,6,0,4,0,0,0,0,8,0,4,...
% 0,0,9,0,0,0,3,0,0,9,1,0,0,0,0,0,1,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,...
% 0,9,0,0,0,2,0,0,7,0,5,0,0,4,0];

if isvector(B)
    siz = sqrt(numel(B));
    if floor(siz) == siz
        B = reshape(B, [siz, siz]).';
    end
end
if ~isnumeric(B) || any(B(:) ~= floor(B(:))) || diff(size(B)) % this includes finding NaN's
    error('Input is not a sudoku board')
end
siz = size(B, 1);
sol = uint16(B);
mx = cast(inf, 'like', sol);
v = cast(1:siz, 'like', sol);
sqrt_siz = sqrt(siz);
is_squared = floor(sqrt_siz) == sqrt_siz;
if is_squared
    vj = v(1:sqrt_siz);
    each_square = repmat(vj.', sqrt_siz, siz) + repmat((vj-1)*sqrt_siz, siz, sqrt_siz) + repelem(reshape((v-1)*siz, [sqrt_siz, sqrt_siz]), sqrt_siz, sqrt_siz);
end

close all
figure("WindowStyle","docked")
P = imagesc(sol.*(mx/siz));
colormap hot


opts = arrayfun(@(x)v, repmat(v, siz, 1), 'UniformOutput', false);
Done = false(siz); % where simple elimination has been done.
while unsolved
    prev_board = sol;
    prev_opts = opts;

    S_E; % Simple Elimination
    H_S; % Hidden Singles
    if is_squared
        OM;  % Omission
        XYW;
    end
    N_T; % Naked Tuplets
    H_T; % Hidden Tuplets
    O_S; % Open Singles
    if isequal(prev_board, sol) && isequal(prev_opts, opts)
        %% DEV
        assignin('base', "OPTS", opts)
        assignin('base', "sol", sol)
        %% DEV
        error('No progress made with known techniques. I failed :(((')
    end
end
if any(B ~= sol & B ~= 0)
    [row,col] = find(B ~= sol & B ~= 0, 1, "first");
    error('My solution is wrong for some reason. See r%d c%d', row, col);
end

%% Check if the sudoku is still unsolved
    function flag = unsolved
        flag = ~all(sol, "all");
    end
%% get all squares that intersect a given square
    function inters = intersud(inds, vi, squared)
        if nargin < 3
            squared = is_squared;
        end
        l = numel(inds);

        flag = nargin > 1 && ~isempty(vi);
        if flag
            if all(isnan(vi)) || ~sum(vi(~isnan(vi))) || l == 0
                inters = [];
                return
            end
            hv = true(1, siz^2);
            hv(vi) = false;
        end

        if squared
            inters = zeros(3*siz-2*sqrt_siz-1, l); % number of intersection points
        else
            inters = zeros(siz*2-1, l);
        end
        for ii = 1:l
            x = false(1, siz^2);
            n = inds(ii);
            if squared
                x(each_square(:, any(each_square == n))) = true; % same square
            end
            x(repmat(v-1, 1, siz) == rem(n-1, siz) | repelem(v-1, 1, siz) == floor((n-1)/siz)) = true; % same row | same column
            x(n) = false; % a square doesn't intersect itself
            if flag
                x(hv) = false;
            end
            inters(1:sum(x), ii) = find(x);
        end
        if size(inters, 2) == 1
            inters = nonzeros(inters);
        end
    end
%% Delete options from opts array
    function delopts(vals, varargin)
        %DELOPTS delete pencil marks from sudoku.
        %   DELOPTS is used to easily delete certain elements from multiple vectors
        %   inside a cell array.
        %
        %   DELOPTS(VALS,IDX) delets values VALS from vectors in the cells in opts
        %   corresponding to the linear indices in IDX
        %
        %   DELOPTS(VALS,R,C) delets values VALS from vectors in the cells in opts
        %   corresponding to subscripts opts{R, C};


        if length(varargin) == 2
            for r = varargin{1}
                for c = varargin{2}
                    for n = vals
                        opts{r, c}(opts{r, c} == n) = [];
                    end
                end
            end
        else
            for idx = varargin{:}
                for n = vals
                    opts{idx}(opts{idx} == n) = [];
                end
            end
        end
    end
%% Open Singles
    function O_S
        for r = v
            for c = v
                if sol(r, c)
                    continue
                end
                temp = opts{r,c};
                if isempty(temp)
                    error('Solver reached a contradiction. r%d c%d can''t be any number', r, c);
                elseif length(temp) == 1
                    sol(r,c) = temp;
                    P.CData = sol.*(mx/siz); drawnow; %pause(0.1)
                end
            end
        end
    end
%% Simple Elimination
    function S_E
        for idx = find(sol).'
            n = sol(idx);
            if n && ~Done(idx)
                delopts(n, intersud(idx).')
                opts{idx} = n;
                Done(idx) = true;
            end
        end
    end
%% Hidden Singles
    function H_S
        % In rows
        LENGTHS = cellfun('length', opts);
        for r = v
            ls = LENGTHS(r, :); % how many options to each cell
            temp = cat(2, opts{r, :}); % contents of unsolved cells
            temp(repelem(ls == 1, ls)) = 0; % unsolved cells only, sorry
            ib = find(sum(temp == temp.') == 1 & temp); % a single
            le_sum = cumsum(ls);
            for x = ib
                c = find(le_sum >= x, 1);
                opts{r, c} = temp(x);
                LENGTHS(r, c) = 1;
            end
        end
        % In columns
        for c = v
            ls = LENGTHS(:, c); % how many options to each cell
            temp = cat(2, opts{:, c}); % contents of unsolved cells
            temp(repelem(ls == 1, ls)) = 0; % unsolved cells only, sorry
            ib = find(sum(temp == temp.') == 1 & temp); % a single
            le_sum = cumsum(ls);
            for x = ib
                r = find(le_sum >= x, 1);
                opts{r, c} = temp(x);
                LENGTHS(r, c) = 1;
            end
        end
        % In the little squares
        if is_squared
            for s = each_square
                ls = LENGTHS(s); % how many options to each cell
                temp = cat(2, opts{s}); % contents of unsolved cells
                temp(repelem(ls == 1, ls)) = 0; % unsolved cells only, sorry
                ib = find(sum(temp == temp.') == 1 & temp); % a single
                le_sum = cumsum(ls);
                for x = ib
                    r = find(le_sum >= x, 1);
                    opts{s(r)} = temp(x);
                    LENGTHS(s(r)) = 1;
                end
            end
        end

    end
%% Omission
    function OM
        % when all the options for number n in row r are in the same
        % square, etc.
        sqr = @(t) reshape(t, [sqrt_siz, sqrt_siz]);
        for r = double(v)
            f = rem(r-1, sqrt_siz) + 1;
            f = vj(vj ~= f) + r - f;
            for n = v
                if sum(sol(f, :) == n, "all") > 1
                    continue
                end
                c = arrayfun(@(x) any(opts{r, x} == n), v);
                part = any(sqr(c), 1);
                if sum(c) ~= 1 && sum(part) == 1 % not already solved and only in one square
                    vh = sqr(each_square(:, any(each_square == (r+(find(c,1)-1)*siz)))); % my square inds
                    vh(rem(r-1, sqrt_siz)+1, :) = [];

                    delopts(n, reshape(vh, 1, siz-sqrt_siz))
                end
            end
        end

        for c = double(v)
            f = rem(c-1, sqrt_siz) + 1;
            f = vj(vj ~= f) + c - f;
            for n = v
                if sum(sol(:, f) == n, "all") > 1
                    continue
                end
                r = arrayfun(@(x) any(opts{x, c} == n), v);
                part = any(sqr(r), 1);
                if sum(r) ~= 1 && sum(part) == 1
                    vh = sqr(each_square(:, any(each_square == (find(r,1)+(c-1)*siz)))); % my square inds
                    vh(:, rem(c-1, sqrt_siz)+1) = [];

                    delopts(n, reshape(vh, 1, siz-sqrt_siz))
                end
            end
        end

        for s = double(v)
            for n = v
                part = sqr(arrayfun(@(x) any(opts{each_square(x, s)} == n), v)); % reusing previous variables cause it's cool
                r = any(part, 2);
                c = any(part, 1);
                if sum(part) ~= 1
                    if sum(r) == 1
                        x = sqrt_siz*rem(s-1, sqrt_siz) + find(r); % my row
                        vh = sqr(v);
                        vh(:, floor((s-1)/sqrt_siz)+1) = []; % columns to erase options from

                        delopts(n, x, reshape(vh, 1, siz-sqrt_siz))
                    end
                    if sum(c) == 1
                        x = sqrt_siz*floor((s-1)/sqrt_siz) + find(c); % my column
                        vh = sqr(v);
                        vh(:, rem(s-1, sqrt_siz)+1) = []; % rows to erase options from

                        delopts(n, reshape(vh, 1, siz-sqrt_siz), x)
                    end
                end
            end
        end
    end
%% XY-Wing
    function XYW
        LENGTHS = cellfun('length', opts);
        idxs = find(LENGTHS == 2);
        for ii = 1:numel(idxs)
            n = idxs(ii);
            wings = intersud(n, idxs);
            if numel(wings) < 2
                continue
            end

            for jj = nchoosek(1:numel(wings), 2).' % checking every combination of 2 wings
                cands_jj = [opts{wings(jj(1))}, opts{wings(jj(2))}]; % two wings
                if isequal(sum([cands_jj, opts{n}] == [cands_jj, opts{n}].'), repelem(2, 1, 6))
                    m = cands_jj(find(sum(cands_jj == cands_jj.') == 2, 1)); % let m be their shared candidate
                    vh = intersect(intersud(wings(jj(1))), intersud(wings(jj(2))));
                    vh(vh == n) = [];
                    if ~isempty(vh)
                        delopts(m, vh) % deleting m as an option from all intersections of the wings
                    end
                end
            end
        end

    end
%% Naked Tuplets
    function N_T
        tuplet_sizes = 2:4;
        V = arrayfun(@(x) nchoosek(v, x).', tuplet_sizes, 'UniformOutput', false); % all combinations of tuplets
        LENGTHS = cellfun('length', opts);
        skip = LENGTHS > reshape(tuplet_sizes, [1,1,numel(tuplet_sizes)]) | LENGTHS == 1;
        % In rows
        for r = v
            for tup_ind = tuplet_sizes-1
                idxs = V{tup_ind};
                idxs(:, any(ismember(idxs, find(skip(r, :, tup_ind))))) = [];
                for ii = idxs
                    to_erase = unique(cat(2, opts{r, ii}));
                    if length(to_erase) <= tup_ind + 1 % if a number of squares share only relatively few options between them
                        delopts(to_erase, r, v(~any(v == ii, 1)));
                    end
                end
            end
        end
        LENGTHS = cellfun('length', opts);
        skip = LENGTHS > reshape(tuplet_sizes, [1,1,numel(tuplet_sizes)]) | LENGTHS == 1;
        % In columns
        for c = v
            for tup_ind = tuplet_sizes-1
                idxs = V{tup_ind};
                idxs(:, any(ismember(idxs, find(skip(:, c, tup_ind))))) = [];
                for ii = idxs
                    to_erase = unique(cat(2, opts{ii, c}));
                    if length(to_erase) <= tup_ind + 1 % if a number of squares share only relatively few options between them
                        delopts(to_erase, v(~any(v == ii, 1)), c);
                    end
                end
            end
        end
        LENGTHS = cellfun('length', opts);
        skip = LENGTHS > reshape(tuplet_sizes, [1,1,numel(tuplet_sizes)]) | LENGTHS == 1;
        % In the little squares
        if is_squared
            for s = each_square
                for tup_ind = tuplet_sizes-1
                    idxs = V{tup_ind};
                    idxs(:, any(ismember(idxs, find(skip(s+numel(skip(:, :, 1))*(tup_ind-1)))))) = [];
                    % making linear indices

                    for ii = idxs
                        to_erase = unique(cat(2, opts{s(idxs)}));
                        if length(to_erase) <= tup_ind + 1 % if a number of squares share only relatively few options between them
                            delopts(to_erase, s(v(~any(v == ii, 1))).');
                        end
                    end
                end
            end
        end

    end
%% Hidden Tuplets
    function H_T
        tuplet_sizes = 2:4;
        V = arrayfun(@(x) nchoosek(v, x).', tuplet_sizes, 'UniformOutput', false); % all combinations of tuplets
        LENGTHS = cellfun('length', opts);
        for r = v
            occurences = groupcounts(cat(2, opts{r, :}).');
            for tup_ind = tuplet_sizes-1
                nums = V{tup_ind};
                vh = occurences > tup_ind+1 | occurences == 1;
                nums(:, any(ismember(nums, find(vh)), 1)) = [];
                for ii = nums
                    temp = any(opts(r, :, nums(: ,ii)), 3);
                    if sum(temp, "all") <= tup_ind + 1 % if certain numbers appear in only a small number of squares
                        opts(r, temp, ~any(v == nums(:, ii), 1)) = 0;
                    end
                end
            end
        end

        for c = v
            occurences = arrayfun(@(x) sum(opts(:, c, :) == x, "all"), v);
            for tup_ind = tuplet_sizes-1
                nums = V{tup_ind};
                vh = occurences > tup_ind+1 | occurences == 1;
                nums(:, any(ismember(nums, find(vh)), 1)) = [];
                for ii = 1:size(nums, 2)
                    temp = any(opts(:, c, nums(: ,ii)), 3);
                    if sum(temp, "all") <= tup_ind + 1 % if certain numbers appear in only a small number of squares
                        opts(temp, c, ~any(v == nums(:, ii), 1)) = 0;
                    end
                end
            end
        end
        if is_squared
            for s = each_square
                occurences = arrayfun(@(x) sum(opts(s{1}, s{2}, :) == x, "all"), v);
                for tup_ind = tuplet_sizes-1
                    nums = V{tup_ind};
                    vh = occurences > tup_ind+1 | occurences == 1;
                    nums(:, any(ismember(nums, find(vh)), 1)) = [];
                    for ii = 1:size(nums, 2)
                        temp = any(opts(s{1}, s{2}, nums(: ,ii)), 3);
                        if sum(temp, "all") <= tup_ind + 1 % if certain numbers appear in only a small number of squares
                            [r,c] = ind2sub([sqrt_siz, sqrt_siz], find(temp));
                            r = r + s{1}(1) - 1;
                            c = c + s{2}(1) - 1;
                            vh = find(~any(v == nums(:, ii), 1)).';
                            idxs = sub2ind([siz, siz, siz], repmat(r, length(vh), 1), repmat(c, length(vh), 1), repelem(vh, sum(temp, "all"), 1));
                            opts(idxs) = 0;
                        end
                    end
                end
            end
        end

    end

end