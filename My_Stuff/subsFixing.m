%%

my_folder = 'C:\Users\anan_\Videos\movies\Galavant\S2E1';
% remove_from_name = '(\..*)?\.en'; % regex
% episode_naming_Mov = 'S\d+E\d+'; % regex
% Subs_naming = ' - 2x%02d '; % in sprintf with wildcards to catch the number of the next episode
% default_Movie_Name = "1080"; % startsWith pattern

% renameMovies(my_folder, d, default_Movie_Name, episode_naming_Mov, Subs_naming)
% renameSubs(my_folder);
fixSubs(my_folder, 'bell', 2)
%% rename subs to make them the same as the movies
function renameSubs(loc)
d = dir(loc);
d(~[d.isdir]) = [];
for ii = 3:size(d, 1)
    down_loc = fullfile(loc, d(ii).name);
    sub = dir([down_loc, filesep, '*.srt']);
    mov = dir([fullfile(loc, d(ii).name), filesep, '*.mp4']);
    if strcmp(sub.name(1:end-4), mov.name(1:end-4))
        continue
    end
    rename(sub.name, mov.name, down_loc);
end
end
%% names of movie
% function renameMovies(loc, dirs, default_Movie_Name, Mov_naming, Subs_naming)
% next_episode = sum(~cellfun(@isempty, regexp(dirs, Mov_naming)));
% oldnames = sort(dirs(startsWith(dirs, default_Movie_Name)));
% for ii = 1:length(oldnames)
%     next_episode = next_episode + 1;
%     oldname = oldnames(ii);
%     if isnothing(oldname)
%         break
%     end
% 
%     pat = sprintf(Subs_naming, next_episode);
%     new_name = dirs(contains(dirs, sprintf(Subs_naming, next_episode)));
%     if isempty(new_name)
%         break
%     end
%     new_name = regexprep(new_name, pat, sprintf(" S2E%d ", next_episode));
%     new_name = regexprep(new_name, "\.srt", "\.mp4");
%     new_name = regexprep(new_name, " +", " ");
%     rename(oldname, new_name, loc);
% end
% end

%% fixing timestamps in the subs

function fixSubs(my_folder, method, val)
%FIXSUBS fixes subs
% FIXSUBS(MY_FOLDER, METHOD, VAL) fixes subs in folder with a movie, using
% METHOD with a value VAL. list of methods and values:
% "stretch" stretches the subs to match the length of the video. VAL is
% subtracted from the length of the video (to match the last line of dialog
% manually).
% "delay" adds VAL seconds equally to all timestamps.
% "bell" adds a bell shaped curve to all values with max value VAL.

my_folder = convertStringsToChars(my_folder);

if ~any(my_folder(end) == filesep)
    my_folder(end+1) = filesep;
end

movies = dir([my_folder, '*.mp4']);
subs = dir([my_folder, '*.srt']);
for ii = 1:size(movies, 1)
    subs_loc = locateSubs(subs, movies(ii).name);
    fixSubs(subs(subs_loc).name, movies(ii).name, my_folder, method);
    new_dir_name = fullfile(my_folder, char(regexp(movies(ii).name, 'S\d+E\d+', 'match')));
    if strcmp(my_folder, new_dir_name)
        continue
    end
    mkdir(new_dir_name);
    movefile(fullfile(my_folder, movies(ii).name), [new_dir_name, filesep, movies(ii).name]);
    movefile(fullfile(my_folder, subs(subs_loc).name), [new_dir_name, filesep, subs(subs_loc).name]);
end

    % locate the subs
    function idx = locateSubs(subs, movie_name)
        l = size(subs, 1);
        S1 = 0;
        idx = 0;
        for i = 1:l
            n = subs(i).name;
            S2 = max([S1, sum(spdiags(n == movie_name.'))]);
            if S2 ~= S1
                idx = i;
                S1 = S2;
            end
        end
    end

    % fix the subs
    function fixSubs(subs, movie, loc, method)
        method = convertCharsToStrings(method);

        Subtable = readSrtFile(fullfile(loc, subs));
        subs_dur = Subtable.t(end);
        for i = 1:numel(method)
            switch method(i)
                case "stretch"
                    time_delay = mov_dur - subs_dur;
                    v = VideoReader([loc, movie]);
                    mov_dur = duration(seconds(v.Duration - val), 'Format', 'hh:mm:ss.SSS'); % ending crap
                    Subtable.t = Subtable.t + linspace(0, time_delay, height(Subtable)).';
                case "delay"
                    Subtable.t = Subtable.t + seconds(val);
                case "bell"
                    Subtable.t = Subtable.t + sign(val).*seconds(pdf(makedist("Normal", "mu", 0, "sigma", 1/(sqrt(2*pi)*abs(val))), linspace(-abs(val)*2, abs(val)*2, height(Subtable)))).';
            end
        end
        writeSrtFile(Subtable, fullfile(loc, subs));

        % read the .srt into a table
        function T = readSrtFile(file)
            A = readlines(file);
            end_indices = find(A == "");
            start_indices = [1; end_indices(1:end-1) + 1];
            
            if any(~matches(A(start_indices), digitsPattern(1,4)))
                error('you suck!')
            end
            
            line = A(start_indices);
            t = split(A(start_indices + 1), ' --> ');
            t = t.replace(",", ".");
            text = arrayfun(@(x) strjoin(A(start_indices(x)+2:end_indices(x) - 1), newline), 1:length(start_indices)).';

            line = str2double(line);
            t = duration(t, 'Format', 'hh:mm:ss.SSS');

            T = table(line, t, text, 'VariableNames', {'line', 't', 'text'});
            T(startsWith(T.text, '<font color='), :) = [];
        end

        % write the table back into .srt
        function writeSrtFile(T, filename)
            fid = fopen(filename, 'w');
            T.t = string(T.t);
            T.t = T.t.replace(".", ",");
            for i = 1:height(T)
                if i > 1
                    fprintf(fid, '\n');
                end
                fprintf(fid, '%d\n%s\n%s\n', T.line(i), strjoin(T.t(i, :), ' --> '), T.text(i));
            end
            fail = fclose(fid);
            if fail
                error('failed to close file %s', filename)
            end
        end
    end

end