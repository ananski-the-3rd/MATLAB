function finalpath = mcollatz(vector, oddadd, maxpath, options1, options2)
arguments
    vector (1, :) {mustBeInteger}
    oddadd {mustBeInteger} = 1
    maxpath {mustBeInteger} = 1e3
    options1 (1, :) char {mustBeMember(options1, {'quick', 'precise'})} = 'quick'
    options2 (1, :) char {mustBeMember(options2, {'stable', 'sorted'})} = 'stable'
end
% MCOLLATZ  PATH = MCOLLATZ(VECTOR, ODDADD, MAXPATH, OPTIONS)
%           applies an iterative process to integers in a vector:
%           -if a number is even, the process divides it by 2
%           -if a number is odd, the process multiplies it by 3 and adds 1
%           (unless a different value was indicated in ODDADD).
%           
%           PATH = MCOLLATZ(VECTOR, MAXPATH) outputs the path of all integers
%           in VECTOR until a loop is reached, or up to the maximum amount of
%           iterations in MAXPATH (MAXPATH is 1000 by default).
%          
%           PATH = MCOLLATZ(VECTOR, ODDADD) can set a different
%           process: if a number is odd, the process multiplies it by 3 and
%           adds ODDADD. Note that ODDADD should itsself be odd.
%
%           option 'quick' calculates on GPU (toolbox needed). 'precise' is
%           on CPU. currently matlab does not support int64 calculations on
%           GPU so that's why CPU is more precise.
%
%           option 'sorted' gives the paths by their lengths. To keep the
%           order of the original vector pick 'stable' (default). the inner
%           workings of mcollatz is such that the 'sorted' option is
%           slightly faster.


try mustBeInteger(0.5 * (oddadd + 1));
catch
    error('Odd explosive loop detected');
end
if strcmp(options1, 'quick')
    path = zeros(maxpath, length(vector), 'gpuArray');
elseif strcmp(options1, 'precise')
    path = zeros(maxpath, length(vector), 'int64');
end



path(2, :) = vector;
finalpath = path;
ii = 1;
for i = 3:maxpath
    uniqind = ~any((path(i - 1, :) == path(1:i - 2, :)), 1);
    if ~all(uniqind)
    countzeros = sum(~uniqind);
    finalpath(2:i, ii:ii+countzeros-1) = path(2:i, ~uniqind);
    ii = ii + countzeros;
    path(:, ~uniqind) = [];
    if isempty(path)
        break
    end
    end
    oddvec = logical(mod(path(i - 1, :), 2));
    path(i, oddvec) = path(i - 1, oddvec) .* 3 + oddadd;
    path(i, ~oddvec) = path(i - 1, ~oddvec) .* 0.5;
end
if strcmp(options2, 'stable')
    [~, pathorder(1, :)] = sort(finalpath(2, :));
    [~, temp] = sort(vector);
    [~, pathorder(2, :)] = sort(temp);
    for jj = 1:2
        finalpath = finalpath(:, pathorder(jj, :));
    end
end
if strcmp(options1, 'quick')
    finalpath = gather(finalpath(2:i - 1, :));
elseif strcmp(options1, 'precise')
    finalpath = finalpath(2:i - 1, :);
end