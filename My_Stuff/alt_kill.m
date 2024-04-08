function [newvec, new_pairs] = alt_kill(charvec, bracket_pairs)
arguments
    charvec (1, :) char = ''
    bracket_pairs = []
end
% This function takes a character vector with '|' and chooses a side for each '|' if
% applicable. can also remove brackets!
%% DEV
% charvec = '(?:(a|ba|c)((e|(a|b)|a)f){1,1}(?:a(d|c))(a(d|c){3,5})(a|(d|c){3,5}))';
%%
newvec = charvec;
if ~any(newvec == '|')
    new_pairs = bracket_pairs;
    return
end
if isempty(bracket_pairs)
bracket_pairs = bracketing(newvec, 'lin_rev', 'levels'); % all brackets pairs
end
bracket_pairs(end+1, :) = zeros(1, size(bracket_pairs, 2));
bracket_pairs(end, 1:2) = [0, length(newvec)+1];
% find bracket pairs which are quantified (we don't want to use alternation
% on quantified brackets).
l_qnt = newvec(bracket_pairs(1:end-1-(newvec(end) == ')'), 2)+1) == '{';
qnt_brks = bracket_pairs(l_qnt, 1:2);

% find alternations inside the quantified bracket pairs and 'protect' them
% from being used
alt_l = newvec == '|';
alt = find(alt_l);
alt = alt(:).'; % forces it to be a row vector cause matlab sucks

if  any(l_qnt)
    backup = repmat(qnt_brks, 1, length(alt));
    alts_to_ignore = any(alt > backup(:, 1:2:end) & alt < backup(:, 2:2:end), 1);
    alt_l(alt(alts_to_ignore)) = 0; % protects said alternations
end

% in the following for loop we only want to use brackets which are NOT
% quantified (directly or embeddedly), thus we remove their ranges from our
% bracket pairs variable.

bracket_pairs(l_qnt, :) = [];
a = 2*(newvec(bracket_pairs(:, 1)+1) == '?').';
bracket_pairs = [bracket_pairs(:, 1) + a + 1, bracket_pairs(:, 2) - 1]; % don't include '?:' or brackets in junctions
junctions = repmat(1:length(newvec), size(bracket_pairs, 1), 1);
junctions = junctions >= bracket_pairs(:, 1) & junctions <= bracket_pairs(:, 2);

for ii = 1:size(bracket_pairs, 1)
    inds = find(junctions(ii, :) & alt_l);
    if any(inds)
        alt_l(inds) = 0;
        junc_ranges = [bracket_pairs(ii, 1), inds+1; ...
                       inds-1, bracket_pairs(ii, 2)];
        choice = junc_ranges(:, randi(size(junc_ranges, 2)));
    else
        choice = bracket_pairs(ii, 1:2);
    end
    choice = choice(1):choice(2);
    choicevec = newvec(choice);
    newvec(junctions(ii, :)) = '-';
    newvec(choice) = choicevec;
end
% KILL
newvec = newvec(newvec ~= '-');
new_pairs = bracketing(newvec, 'lin_rev', 'levels');

%% for debugging
% fprintf('\n%s\n%s\n', charvec, newvec);
%%
end
