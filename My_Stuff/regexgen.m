function rndpat = regexgen(r_e, amount)
arguments
    r_e char = ""
    amount (1,1) {mustBeInteger} = 1
end
%REGEXGEN generate a random pattern using regular expressions
%   REGEXGEN(r_e, amount) generates n (n = amount) random strings that
%   match r_e. amount is 10 by default.
%   special syntax: "?>" means don't take tokens in this bracket or its
%   embedded brackets.
%   Currently it's possible to use lookarounds that match one character,
%   without embedded brackets in the lookaround test.

rndpat = strings(amount, 1);

escchr = '\\.';
anychr = '[^\r\n\]\\]';
quant = '(?:[*+?]|{\d+,?\d*})\??';
chrcls = ['\[(?:', anychr, '|', escchr, ')*\]'];
anychr(8) = '[';
grpexp = '(?<=\()\?[:>]';
expression = ['(', escchr, '|', chrcls, '|', grpexp, '|', quant, '|', anychr, ')'];
lookies = ['(?:\(\?(=|!)', '[^\r\n\)]+', '\))'];
expression = [lookies, '?' expression];
r_e = regexprep(r_e, ['(', lookies, ')', '\(', expression, '\)'], '\($1$2\)');
r_e = string(regexp(r_e, expression, "match")); % parases regex to splits into regex units.

% turn all quantifiers to the pattern '{\d+,\d+}'
replaceunit = r_e(2:end);
replaceunit(startsWith(r_e(2:end), '*')) = '{0,}';
replaceunit(startsWith(r_e(2:end), '+')) = '{1,}';
replaceunit(r_e(2:end) == '?' | r_e(2:end) == '??') = '{0,1}';
replaceunit = regexprep(replaceunit, '{(\d+),}', '{$1,12}');
replaceunit = regexprep(replaceunit, '{(\d+)}', '{$1,$1}');
replaceunit = regexprep(replaceunit, '{(\d+),(\d+)}\??', '{$1,$2}');
r_e(2:end) = replaceunit;
% the following characters have special meaning and thus will be kept as
% they are.
specials = r_e == '(' | r_e == ')' | r_e == '|' | r_e == '?:' | r_e == '?>' | startsWith(r_e, '{' + digitsPattern + ',' + digitsPattern + '}');
% each regex unit is turned into a placeholder char (from char(192) onward)
% for speed. take extra care if your regex tries to match weird characters
% that are ascii 192 onward.
jj = 191;
og_unit = string(char((1:length(r_e))+jj)')';
og_unit(specials) = r_e(specials);
% save original 'unit' vector and bracket pairs as they do not have to be
% re-calculated for each iteration.
og_unit = char(strjoin(og_unit, ''));
og_brk2s = bracketing(og_unit, 'lin_rev', 'levels');
% these characters will be matched at the end.
properchars = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

% loop for amount
for ind0 = 1:amount

    [unit, brk2s] = alt_kill(og_unit, og_brk2s);
    if ~isempty(brk2s)
        m = max(brk2s(:, 3)); % max_levels
        max_index = [1:(m*2),(m*2):-1:1]; % for loop initiation
    else
        max_index = [];
    end

% loop for quantifications (goes by brackets from out to in).
    for ntm = max_index % ntm is not too much
        if isempty(brk2s)
            continue
        end
        mybrk = brk2s(brk2s(: ,3) == ntm, 1:2);
        if isempty(mybrk)
            continue
        end
        i1 = size(mybrk, 1);
        qnt_l = true(1, i1);
        if mybrk(i1, 2) >= length(unit)-2
            qnt_l(i1) = false;
            m = 1;
        else
            m = 0;
        end
        for i1 = (i1-m):-1:1
        qnt_l(i1) = unit(mybrk(i1, 2)+1) == '{';
        end
        if ~any(qnt_l)
            continue
        end
        qnt_indices = mybrk(qnt_l, 2) + 1;
        qnt_ranges = arrayfun(@(x) strtok(unit(qnt_indices(x)+1:end), '}'), 1:length(qnt_indices), 'UniformOutput', false);
        my_qnt = str2double(split(string(qnt_ranges), ',', 1));
        howmany = ones(size(mybrk, 1), 1);
        if isempty(howmany)
            continue
        end
        howmany(qnt_l) = arrayfun(@(x)randi(my_qnt(:, x)), (1:sum(qnt_l)));
        howfix = ones(size(mybrk, 1), 1);
        howfix(qnt_l) = cellfun(@length, qnt_ranges) + 3;
        
        % initiating stuff for my loop
        hmat = repmat(1:length(unit), length(howmany), 1);
        dupliparts =  hmat >= mybrk(:, 1) & hmat <= mybrk(:, 2);
        
        for i1 = length(howmany):-1:1
            if howmany(i1) == 0
                insertion = '';
            elseif howmany(i1) == 1
                insertion = unit(dupliparts(i1, :));
            else % leave tokens unmolested
                insertion = ['(', '?>', (repmat(unit(dupliparts(i1, :)), 1, howmany(i1)-1)), ')', unit(dupliparts(i1, :))];
            end
            unit = [unit(1:mybrk(i1, 1) - 1), char(insertion), unit(mybrk(i1, 2) + howfix(i1):end)];
        end
        brk2s = bracketing(unit, "lin_rev", "levels");
    end

    [unit, brk2s] = alt_kill(unit, brk2s);

    if ~isempty(brk2s)
        mytokens = (unit(brk2s(:, 1)+1) ~= '?').';
        nontokens = brk2s(unit(brk2s(:, 1)+2) == '>', 1:2).';
        to_check = repmat(nontokens, size(brk2s, 1), 1);
        tokens_to_delete = any(brk2s(:, 1) > to_check(1:2:end, :) & brk2s(:, 2) < to_check(2:2:end, :), 2);
        unit(brk2s((~mytokens|tokens_to_delete), 1:2)) = [];
        unit = regexprep(unit, '\?[:>]', '');
    end
    if isempty(unit)
        rndpat(ind0) = "";
        continue
    end


    chk_qnt = find(unit == '{') - 1;
    my_qnt = str2double(split(string(regexp(unit, '{(\d+,\d*)}','tokens')).', ',', 1));
    howmany = ones(size(unit));
    try
        howmany(chk_qnt) = arrayfun(@(x)randi(my_qnt(:, x)), 1:size(my_qnt, 2));
        unit = repelem(unit, howmany);
        unit = regexprep(unit, '{\d+,\d*}','');
    catch
    end


    tokens = bracketing(unit, 'lin_sort', 'simple');
    if ~isempty(tokens)
        % get indices of tokens after their brackets are deleted
        hmat = repmat(tokens(1:size(tokens, 1)*2), size(tokens, 1), 1);
        tokens = tokens - [sum(tokens(:, 1) > hmat, 2), sum(tokens(:, 2) > hmat, 2) + 1];
        unit(unit == '(' | unit == ')') = [];
    end

    master_indices = unit - jj;
    unit = r_e(master_indices);
    backreferences = matches(unit, "\" + digitsPattern(1));
    i2_vec = 1:length(unit);
    for i2 = i2_vec(~backreferences)
        flag = 0;
        charcell = regexp(properchars, unit(i2), 'match');
        try
            unit(i2) = charcell(randi(length(charcell)));
        catch
            rndpat(ind0) = missing;
            flag = 1;
            break
        end
    end
    if flag
        continue
    end
    for i2 = i2_vec(backreferences)
        t_no = str2double(unit{i2}(2:end));
        try
            a = tokens(t_no, 2) < i2;
            unit(i2) = strjoin(unit(tokens(t_no, a):tokens(t_no, 2)), '');
        catch
            unit(i2) = "";
        end
    end

    rndpat(ind0) = strjoin(unit, '');

    %%DEV
%     fprintf('%s\n', strjoin(unit, ''))
    %%
end
end
