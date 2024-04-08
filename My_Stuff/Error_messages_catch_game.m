prompt1 = ('Tell me a joke: ');
lolz = 0;
while ~lolz
    joke = input(prompt1,'s');
    len_check = '';
    if length(joke) >= 400
        len_check = 'long';
    elseif length(joke) <= 1
        len_check = 'short';
    end
    if ~isempty(len_check)
        prompt1 = sprintf('Way too %s, dude!\nTry again: ',len_check); continue
    elseif regexp(joke,'^[01]$','once') == 1
        disp('You know me so well'); lolz = 1; break
    else
        lolz = isfunny(joke);
    end
    if lolz
        load laughter
        sound(y)
        return
    else
        prompt1 = 'I do not understand this language\nTry again: '; continue
    end
end

%%
function lojique = isfunny(feedline)

if ~ischar(feedline)
    error('Input must be a character vector')
end
% checker = {'What', 'Why', 'Who', 'When', 'Where', 'How many', 'How much', 'whol', 'asdgkhaskg'};
bank = '\<Wh(at|y|o|en|ere)|How( many| much)?\>';
match_exp = sprintf('(%s)[^?.!]*(\\?)', bank);
question = regexprep(feedline, match_exp, '$1$2','ignorecase');
if isequal(feedline,question)
    lojique = 0; return
else
    disp(question);
    punchline = input('', 's');
end
if ~isempty(punchline)
    lojique = 1;
else
    lojique = 0;
end

end