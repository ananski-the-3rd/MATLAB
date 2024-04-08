re = {'';...
    'a{2a,3}';...
    'a{2,a3}';...
    'a{,1e2}';...
    'a{1e1,}';...
    'a{1,4}';...
    'a{1,}';...
    '{2,3}{4,5}';...
    '????????';...
    '(?:((a|b){1}\2|c)|d)\1(Sabas{1}ba){1}';...
    '(?>((a1|e1)?|i1)?|(o1))*|([sz](([aeiou])|([aeiou][bdpt]))){2,3}r+(u|oo){1,2}(\1)(?:(\?|\!|\?\!)|(\.{3}))?\(';...
    '(?:0[1-9]|[12]\d|3[01])([- /.])(?:01|03|05|07|08|10|12)\1(?>(19|20)\d\d)|(?:0[1-9]|[12]\d|30)([- /.])(?:04|06|09|11)\2(?>(19|20)\d\d)|(?:0[1-9]|[12]\d)([- /.])02\3(?>(19|20)\d\d)';...
    '(1(2|(3){2}){2}){2}\1\2\3';...
    '([aeiou])(\d{2})';...
    '()(b)(c(d))((e)f(g))(h(i)j(k(l)m)n)o';...
    'abc|(lala{2}|(b?a(ba){1,3}))(a|b)|\w{2,}';...
    '[^ACEGIKMOQSa-z?-@][\]\-\\][!-z\\\'};



for ii = 1:length(re)
    randwords = regexpgen(re{ii}, 100);
end

function randwords = regexpgen(re, n, varargin)
% VERSION: 24/01/2023
% REGEXPGEN generates data that matches a regular expression

%%
% to do list:
% 1. add weigthed alternations
% 2. add conditionals
% 3. add deterministic all-combinations generator
%%

re = convertStringsToChars(re); % regular expression input

if nargin < 3
    mi = 31;
    ma = 127;
else
    mi = [varargin{:}];
    ma = mi(2)*1; % convert to double, input can be 'א':'ת'
    mi = mi(1)*1;
end
if nargin < 2
    n = 1;
end

Specials = [9:10];
Specials(2, :) = ma-mi+(1:length(Specials)); % indices of specials in bank
bank = char([mi+1:ma, Specials(1, :)]);
% DON'T TOUCH THE BANK TILL THE SPACE CHARACTER
tkn_counter = 1;
max_quantity = 12;


S = Parse(re, 0);

tokens = cell(1,10);
match_alts = zeros(1,10);
grp_alts = strings(1,10);
ia = 1;
tkn_counter = true;

randwords = regen(S, n);


    function S = Parse(re, t)
        if nargin < 2
            t = 0; % t determines if it's a token or not
        end
        l = length(re);
        if l == 0
            S = struct('type', 1, 'n', 1, 'C', '');
            return
        end
        ii = 1; % index on input regular expression
        io = 1; % index on output
        S = struct('type', [], 'n', [], 'C', ''); % type is type, n is multiplier, C is content
        N = num2cell(ones(l, 1)); % preallocate 
        [S(1:l).n] = N{:};

        %% TYPES: 1 - normal, 2 - class, 3 - brackets, 3.1 - brackets non token, 3.2 - atomic brackets, 4 - alternation, 4.1 - matched alternations, 5 - tokens, 6 - conditionals
        while ii <= l
            next = re(ii); % current character
            if (ii == l && any(next == '{[(\')) || (ii == 1 && any(next == '{*+?'))
                Literal(1);
                continue
            end
            switch next
                    %WILDCARD%
                case '.'
                    S(io).type = 2;
                    S(io).C = bank(1:ma-mi);
                    %CHARCLASS%
                case '['
                    range = charClass();
                    if ih > l
                        Literal(1);
                        continue
                    end
                    S(io).type = 2;
                    S(io).C = bank(range);
                    ii = ih;
                    %##############################################%
                case '\'
                    ii = ii + 1;
                    next = re(ii);
                    if any(next == '0':'9') % can have \01 as token instead of \1
                        ih = ii + 1;
                        while ih <= l && any(re(ih) == '0':'9')
                            ih = ih + 1;
                        end
                        S(io).type = 5;
                        S(io).C = re(ii:ih-1);
                        ii = ih-1;
                    else
                        [idx, S(io).type] = escChar();
                        S(io).C = bank(idx);
                    end
                    %##############################################%
                case '('
                    ih = ii + 1; % helper index
                    atomic = false;
                    lev = 1; % level
                    while lev && ih <= l
                        if re(ih) == ')'
                            lev = lev - 1;
                        elseif re(ih) == '('
                            lev = lev + 1;
                        end
                        ih = ih + 1;
                    end
                    if lev
                        Literal(1);
                        continue
                    end
                    S(io).type = 3 + t;
                    if re(ii+1) == '?'
                        if re(ii+2) == ':'
                            S(io).type = 3.1;
                            ii = ii + 2;
                        elseif re(ii+2) == '>'
                            S(io).type = 3.2;
                            atomic = true;
                            t = 0.1;
                            ii = ii + 2;
                            % DEV MORE FEATURES TO BE IMPLEMENTED LATER
                        

                        end
                    end
                    if S(io).type == 3
                        S(io).tkn = tkn_counter;
                        tkn_counter = tkn_counter + 1;
                    end
                    S(io).C = Parse(re(ii+1:ih-2), t);
                    ii = ih - 1;
                    if atomic
                        t = 0;
                    end

                    %##############################################%
                case '{'
                    if ~isequal(S(io-1).n, -1)
                        Literal(1)
                        continue
                    end
                    qnt = [nan,nan];
                    ii = ii + 1;
                    ih = ii;

                    % first quant
                    while ih <= l && ~any(re(ih) == ',}')
                        ih = ih + 1;
                    end
                    if ih > l || ih == ii
                        Literal(0);
                        continue
                    end
                    qnt(1) = str2double(re(ii:ih-1));
                    if isnan(qnt(1))
                        Literal(0);
                        continue
                    elseif re(ih) == '}' % a '{\d}' pattern quant
                        S(io-1).n = qnt(1);
                        ii = ih + 1;
                        continue
                    end
                    ih = ih + 1; % we definitely hit a ',' so we go on

                    % second quant
                    if re(ih) == '}'
                        if re(ih-2) == '{' % a '{,}' pattern
                            Literal(0)
                        else
                            qnt(2) = max(qnt(1), max_quantity);
                            S(io-1).n = qnt;
                            ii = ih + 1;
                        end
                        continue
                    else
                        ih2 = ih;
                        while ih2 <= l && re(ih2) ~= '}'
                            ih2 = ih2 + 1;
                        end
                        if ih2 > l
                            Literal(0);
                            continue
                        end
                        qnt(2) = str2double(re(ih:ih2-1));
                        if any(isnan(qnt)) || qnt(1) > qnt(2)
                            Literal(0)
                            continue
                        else % literal
                            S(io-1).n = qnt;
                            ii = ih2 + 1;
                            continue
                        end
                    end
                    %##############################################%
                case '|'
                    nn = 1;
                    ih = ii + 1;
                    S(io).type = 4;
                    if re(ih) == '?' && re(ih+1) == '<'
                        ih = ih + 2;
                        while ih <= l && any(re(ih) == char([17:26, 34:59, 64, 66:91]))
                            ih = ih + 1;
                        end
                        if ih < l && re(ih) == '>' && ih > ii+3
                            S(io).type = 4.1;
                            S(io).grp = re(ii+3:ih-1);
                            ii = ih;
                        else
                            ih = ii + 1;
                        end
                    end
                    if ii == 1
                        S(io).C(nn).Alt = struct('type', 1, 'n', 1, 'C', '');
                    else
                        S(io).C(nn).Alt = S(1:io-1);
                    end
                    S = S(io);
                    lev = 0;
                    while ih <= l
                        if re(ih) == '|' && ~lev
                            nn = nn + 1;
                            S.C(nn).Alt = Parse(re(ii+1:ih-1), t);
                            ii = ih;
                        elseif re(ih) == '\'
                            ih = ih + 1;
                        elseif re(ih) == ')'
                            if lev > 0
                                lev = lev - 1;
                            end
                        elseif re(ih) == '('
                            lev = lev + 1;
                        end
                        ih = ih + 1;
                    end
                    nn = nn + 1;
                    S.C(nn).Alt = Parse(re(ii+1:ih-1), t);
                    return
                    %##############################################%
                case '?' % expand on quantifiers later maybe
                    if ~isequal(S(io-1).n, -1)
                        Literal(1) % DEV make lazy quantifiers later
                        continue
                    end
                    io = io - 1;
                    S(io).n = [0,1];
                    %##############################################%
                case '+'
                    if ~isequal(S(io-1).n, -1)
                        Literal(1) % DEV make lazy quantifiers later
                        continue
                    end
                    io = io - 1;
                    S(io).n = [1,max_quantity];
                    %##############################################%
                case '*'
                    if ~isequal(S(io-1).n, -1)
                        Literal(1)
                        continue
                    end
                    io = io - 1;
                    S(io).n = [0,max_quantity];
                    %##############################################%
                otherwise
                    S(io).type = 1;
                    S(io).C = next;
            end

            ii = ii + 1;
            io = io + 1;

        end
        S(cellfun(@isempty, {S.type})) = [];
        %#%
        function Literal(d)
            S(io).type = 1;
            S(io).C = next;
            ii = ii + d;
            io = io + 1;
        end
        %#%
        function range = charClass
            ih = ii + 1;
            if re(ih) == '^'
                range = true(1, length(bank));
                yn = false;
                ih = ih + 1;
            else
                range = false(1, length(bank));
                yn = true;
            end
            if ih <= l && re(ih) == ']'
                range(re(ih)-mi) = yn;
                ih = ih + 1;
            end
            while ih <= l && re(ih) ~= ']'
                if re(ih) == '-' && ih < l-1 && ih > ii + 1 + ~yn && re(ih+1) ~= ']'
                    if re(ih+1) == '[' % subtracted charclass
                        ih = ih + 2;
                        range(charClass) = false;
                        ih = ih + 1;
                    else
                        range((re(ih-1):re(ih+1))-mi) = yn;
                        ih = ih + 2;
                    end
                elseif re(ih) == '\' && ih < l-1
                    ih = ih + 1;
                    next = re(ih);
                    range(escChar) = yn;
                    ih = ih + 1;
                else
                    range(re(ih)-mi) = yn;
                    ih = ih + 1;
                end
            end
        end
        %#%
        function [idx, type] = escChar
            switch next
                case 'd'
                    type = 2;
                    idx = 17:26;
                case 'D'
                    type = 2;
                    idx = [1:16, 26:ma-mi];
                case 'w'
                    type = 2;
                    idx = [17:26, 34:59, 64, 66:91];
                case 'W'
                    type = 2;
                    idx = [1:16, 27:33, 60:63, 65, 92:ma-mi];
                case 'n'
                    type = 1;
                    idx = Specials(2, Specials(1, :) == 10);
                case 't'
                    type = 1;
                    idx = Specials(2, Specials(1, :) == 9);
                    % DEV and so on
                otherwise
                    type = 1;
                    idx = next*1;
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function randwords = regen(S, n)

        randwords = strings(n, 1);
        if tkn_counter
            is_outer_level = true;
            tkn_counter = false;
        else
            is_outer_level = false;
        end
        for nn = 1:n
            % initialize variables
            if is_outer_level
                tokens = cell(1,10);
                match_alts = cell(1,10);
                grp_alts = strings(1,10);
                ia = 1;
            end
            addition = "";
            % initiate solution of CFG
            for ii = 1:size(S, 2)
                S(ii).n = abs(S(ii).n);
                        if length(S(ii).n) == 1
                            q = abs(S(ii).n);
                        else
                            q = randi(abs(S(ii).n));
                        end
                switch floor(S(ii).type)
                    case 1 % normal
                            addition = repelem(S(ii).C, 1, q);
                    case 2 % class
                            addition = S(ii).C(randi(length(S(ii).C), 1, q));
                    case 3 % brackets
                        str = regen(S(ii).C, q);
                        addition = strjoin(str, "");
                        if S(ii).type == 3 && ~isempty(str)
                            tokens{S(ii).tkn} = str(end);
                        end
                    case 4 % alternations
                        str = strings(q, 1);
                        cc = randi(length(S(ii).C), 1, q);
                        if S(ii).type == 4.1
                            jj = find(strcmp(S(ii).grp, grp_alts));
                            if isempty(jj)
                                match_alts{ia} = cc;
                                grp_alts(ia) = S(ii).grp;
                                ia = ia + 1;
                            else
                                cc = match_alts{jj};
                                if length(S(ii).C) < cc
                                    cc = length(S(ii).C);
                                end
                            end
                        end
                        for jj = 1:q
                            str(jj) = regen(S(ii).C(cc(jj)).Alt, 1);
                        end
                        addition = strjoin(str, "");
                    case 5 % tokens
                        cc = str2double(S(ii).C);
                        if cc < 1 || cc > length(tokens) || isempty(tokens{str2double(S(ii).C)})
                            addition = '';
                        else
                            addition = repmat(tokens{str2double(S(ii).C)}, 1, q);
                        end

                    otherwise % DEV not yet implemented

                end
                randwords(nn) = randwords(nn) + addition;
            end
        end
    end
end
