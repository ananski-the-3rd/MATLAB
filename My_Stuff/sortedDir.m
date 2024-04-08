function d = sortedDir(p)
% This function determines the best way to sort a set of folders
% before returning a structure containing their names.
if ~nargin
    p = pwd;
end
d = dir(p);
[~, fnames] = fileparts({d.name});
rem = strcmp(fnames, '.') | cellfun(@isempty, fnames);
d(rem) = []; fnames(rem) = [];
idxs = str2double(regexp(fnames, '^\d+', 'once', 'match'));
if all(isnan(idxs)) || numel(unique(idxs)) ~= numel(idxs)
    idxs = str2double(regexp(fnames, '\d+$', 'once', 'match'));
end
if all(isnan(idxs)) || numel(unique(idxs)) ~= numel(idxs)
    idxs = [d.datenum];
end
[~, idxs] = sort(idxs);
d = d(idxs);