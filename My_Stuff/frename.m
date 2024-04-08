function frename(oldname, newname, loc)
%FRENAME renames a file. If file is .m file, FRENAME also changes references
%to the file in all user-made functions on the MATLAB path.

% FRENAME(OLDNAME, NEWNAME, LOC) renames the file OLDNAME into NEWNAME in
% directory LOC. Doesn't move the file. 

if nargin < 3
    loc = '';
end

file_on_path = which(fullfile(loc, oldname));
is_on_path = ~isempty(file_on_path);
if is_on_path
    [loc, oldname, ext] = fileparts(file_on_path);
else
    [~, oldname, ext] = fileparts(oldname);
end

[~, newname, ext2] = fileparts(newname);
if isempty(ext2)
    ext2 = ext;
end
is_m_file = strcmp(ext, '.m') && strcmp(ext2, '.m');

if ~is_m_file || ~is_on_path
    [success, msg] = movefile(fullfile(loc, strcat(oldname, ext)), fullfile(loc, strcat(newname, ext2)));
    if ~success
        error(msg)
    end
    return
end


% an .m file on path
answer = input(sprintf('\nAlso rename all references to %s? [y/n/c]: ', strcat(oldname, ext)), 's');
if strcmp(answer, 'c')
    prompt_user = true;
elseif ~strcmp(answer, 'y')
    return
else
    prompt_user = false;
end
tic



fp = strsplit(path, pathsep);
fp(contains(fp, matlabroot)) = [];

[~, P] = grep('-s -If \.m', oldname, fp);
if isempty(P.files)
    return
end
[oldname, newname] = convertStringsToChars(oldname, newname);

for ii = 1:length(P.files)
    replaceInFile(P.files{ii}, P.line(P.findex == ii), oldname, newname)
end
[success, msg] = movefile(fullfile(loc, strcat(oldname, ext)), fullfile(loc, strcat(newname, ext2)));
if ~success
    error(msg)
end

    function replaceInFile(file, line_idxs, old, new)
        Lines = readlines(file);
        for i = 1:length(line_idxs)
            old_line = Lines(line_idxs(i));
            new_line = regexprep(old_line, strcat('(?<!\w)', old, '(?!\w)'), new);
            if prompt_user && ~strcmp(old_line, new_line)
                fprintf('\nchanging line %d in file %s\nfrom:\n%s\nto:\n%s\n', line_idxs(i), file, old_line, new_line);
                a = input('Press s to skip, any other key to replace: ', 's');
                if strcmp(a, 's')
                    continue
                end
            end
            Lines(line_idxs(i)) = new_line;
        end
        NewLines = regexprep(Lines, ['(%.*)', upper(old)], ['$1', upper(new)]);
        if prompt_user
            changes = ~strcmp(Lines, NewLines);
            if any(changes)
                fprintf('\nChanging also in comments:')
                fprintf('\n%s', NewLines{changes})
                a = input('\nApprove changes to comments? [y/n]: ', 's');
                if strcmp(a, 'n')
                    NewLines = Lines;
                end
            end
        end

        writelines(NewLines, file);
        
    end
end