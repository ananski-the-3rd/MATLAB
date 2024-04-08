%MAZE DEBUG
addpath(genpath('MAZE'));
idx = 0;
a = strings(1, 100);
b = strings(1, 100);
for ii = 1:8
    my_str = regexgen(sprintf('\\*(/\\*){%d}\\.txt', ii));
    s = dir(my_str);
    for jj = 1:length(s)
        if contains(s(jj).folder, "MAZE")
            idx = idx + 1;
            my_file = fullfile(s(jj).folder, s(jj).name);
            a(idx) = fileread(my_file);
            b_try = string(regexp(s(jj).folder, 'PATH_\d*$', "match"));
            if ~isempty(b_try)
                b(idx) = b_try;
            end
        end
    end
    if ~isempty(jj)
    end
end
a(strlength(a)==0) = [];
b(strlength(b)==0) = [];
b = unique(b);
for ii = 1:length(a)
    fprintf('\n-----------------------------\n');
    disp(a(ii))
end


rmpath(genpath('MAZE'));