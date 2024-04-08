%% The_6174
% Take any 4 non-identical digits, (e.g. 1523)
% 1. sort them from highest to lowest (5321)
% 2. substract from the same digits flipped (5321-1235 = 4086)
% 3. repeat 1-2 (8640-468 = 8172)
% ...
% Kaprekar showed that you'll (almost) always get looped on 6174!
% (7641-1467 = 6174)

%% input
cond_vec = [1 1 1 1];
prompt1 = ('Choose 4 digits: ');
bank = {'{}', '[]', '()', '''''', '''''''''', '""'};
while any(cond_vec)
    in_str = input(prompt1,'s');
    if length(in_str) >= 50
        prompt1 = 'Way too long, dude!\nTry again: ';
        continue;
    end
    %% Trimming and Jokes
    in_str = strrep(in_str, ' ', ''); % remove blanks
    %be real lol
    if ~isempty(regexp(in_str, '''''\d+''''|"\d+"', 'once'))
        prompt1 = 'No "fake digits" next time please\n(you can use single quotes)\nChoose 4 digits: ';
        continue
    end
    % remove the allowed brackets in order {[('')]}
    for i = 1:5
        if isempty(in_str) %Blank input
            disp('Empty input, abort!');
            return;
        elseif isequal(in_str([1,end]), bank{i}) && i ~= 5
            in_str = in_str(2:end-1);
        end
    end

    if length(in_str) > 2 % don't bother searching if string is too short
        % allow the right pattern of commas or dots
        if regexp(in_str, '^\w+([,.])\w+(?:\1\w+)*$','once') % find commas or periods, let input be valid if 4 digits are separated by commas or periods but not both
            in_str = erase(in_str, "." | ",");
        end
    end
    in_num = str2double(in_str); % convert string to a number
    if contains(in_str,'69'); disp([' NOICE']'); end % IDK why
    %% Error Detection
    cond_vec = [in_num < 0, numel(in_str) ~= 4, isnan(in_num) || ~isempty(regexp(in_str,'[e,\.]','once')), mod(in_num,1111) == 0];
    if cond_vec(1) %negatives suck
        prompt1 = ('\nBe positive!: ');
    elseif cond_vec(2) && cond_vec(3) %for facerollers
        prompt1 = ('\n**4 DIGITS**\nTry again: ');
    elseif cond_vec(2) %Can't count
        prompt1 = ('\n**4** digits\nTry again: ');
    elseif cond_vec(3) %smartass
        prompt1 = ('\n4 **DIGITS**\nTry again: ');
    elseif cond_vec(4) %same digit (special idiot)
        prompt1 = ('\nTry non-identical digits: ');
    end
end
%% Variables and Calculation
ab_char = sort(num2str(in_num));
a = str2double(ab_char);
b = str2double(flip(ab_char));
for j = logspace(1,3,3); if b < j ; b = 10*b; end; end
%% The stuff
for i = 1:10
    c = b - a;
    fprintf('\n%d. %d - %d = %d\n', i, b, a, c);
    if c == 6174; break; end
    ab_char = sort(num2str(c));
    a = str2double(ab_char);
    b = str2double(flip(ab_char));
    if b < 1e3 ; b = 10*b; end
end
if i == 1
    nice_touch = '';
else
    nice_touch = 's';
end
fprintf('\nWe have reached Kaprekar''s constant in %d move%s\n', i, nice_touch);