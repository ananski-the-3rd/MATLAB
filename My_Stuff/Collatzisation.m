%% Collatzisation
% initiating variables
addodd = 201;
maxnum = 1e7;

% constants
cutoff = 2^16;
maxloopno = 1e3;
jvec = zeros(1, addodd + 1);
jvec(1:2:end-1) = 1:2:addodd; jvec(2:2:end) = -1:-2:-addodd;
if maxnum > 2 * cutoff
    chunks = floor(maxnum/(cutoff));
    protocol = zeros(2, chunks + 2);
    protocol(1, :) = [addodd+2, linspace(cutoff, cutoff*(chunks), chunks) - 1, maxnum];
else
    chunks = -1;
    protocol = zeros(2, chunks + 2);
    protocol(1, 1:chunks+2) = maxnum;
end
protocol(2, 1:chunks+2) = floor(50*log(protocol(1, 1:chunks+2))) + 100;


% gathering statistics
loopmat = zeros(100, (length(jvec)));
loopmat(1, :) = abs(jvec);

% initiating calculation
for j = jvec % to check every odd number you can add
    if j > 0
        tempcols = zeros(maxloopno, 2);
        lrn = 0;
    end
    for chunki = 1:chunks+2
        % the magic happens
        if chunki == 1
            path = mcollatz(1:2:protocol(1, chunki), j, protocol(2, chunki), 'precise', 'sorted');
        else
            path = mcollatz(protocol(1, chunki - 1)+mod(j,4)+1:4:protocol(1, chunki), j, protocol(2, chunki), 'precise', 'sorted');
        end
        loopind = path ~= 0;
        last = loopind & flipud(cumsum(flipud(loopind), 1)) == 1;
        loopind = path(last)' == path;
        zerocols = ~logical(sum(loopind) - 1);
        if any(zerocols)
            firstzero = find(zerocols, 1, 'first');
            zerocols(firstzero) = 0;
            a = find(path(:, firstzero) == 0, 1, 'first');
            if isempty(a)
                error('maxpath too low, first zerocol')
            end
            path(:, firstzero) = [path(a-1:a, firstzero); zeros(size(path, 1)-2, 1)];
            loopind(:, firstzero) = [1; 1; zeros(size(path, 1)-2, 1)];
            loopind(:, zerocols) = [];
            path(:, zerocols) = [];
        end
        loopind = loopind | cumsum(loopind) == 1;
        path(~loopind) = inf;
        loopmin = min(abs(path)).*sign(min(path)) * sign(j);
        [loopmin, uniqloops] = unique(loopmin, 'stable');
        path = path(:, uniqloops);
        looplen = sum(path < int64(inf)) - 1;
        try tempcols(lrn+1:lrn + length(loopmin), :) = [loopmin', looplen'];
        catch
            error('maxloopno too low');
        end
        lrn = lrn + length(loopmin);
    end
    if j < 0
        tempcols = tempcols(1:lrn, :);
        tempcols = unique(tempcols, 'rows', 'stable');
        loopmat(2:size(tempcols, 1) + 1, abs(j):abs(j)+1) = tempcols;
    end
end
loopmat(~any(loopmat, 2), :) = [];
loopmat = gather(loopmat);


clearvars -except loopmat addodd maxnum
%OPTIONAL: msgbox("All Done!","noice");
load handel
sound(y)
