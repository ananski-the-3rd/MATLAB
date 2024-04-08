p = 6;
deck = repelem(["NA";"rune";"cthulhu"], [4*p-1,p,1]);
games = 1e4;
score = table(zeros(games, 1), strings(games, 1), strings(games, 1), 'VariableNames', {'nummoves', 'result', 'handicap'});
nummoves = zeros(1,games);
strat = 1;
a = 0;
for ii = 1:games
    [score(ii, :)] = playgame(p, a, deck, strat);
end
function stats = playgame(p, a, deck, strat)
bads = randperm(p, 2);
next = randi(p);
stratflag = 0;
flag = 1;
isgood = zeros(1, p);

for ii = 1:4 % rounds
    ord = randperm(length(deck));
    hands = reshape(deck(ord), 6-ii, p);

    for jj = 1:p
        A = [sum(hands == "NA"); sum(hands == "rune"); sum(hands == "cthulhu"); sum(ismissing(hands))];
        if sum(isgood ~= 0) == 4
            isgood(isgood == 0) = -0.1;
        end
        
        handscores = (0.0001:0.0001:0.0001*p) + (A(2,:) - 5*A(3,:))./(6-ii-(A(4, :))) + isgood;
        if sum(A(2, :)) == a+1
            flag = 0;
            handscores(logical(A(2,:))) = handscores(logical(A(2,:)))+ 100;
        end
        handscores(next) = nan;
        if strat == 1
            if stratflag
                if any(next == bads)
                    if sum(A(2, :)) == a+1 && A(2, bads(bads ~= next)) || isnan(handscores(bads(bads ~= next)))
                        next = find(handscores == min(handscores));
                        choice = find(~ismissing(hands(:, next)), 1);
                        flag = 0;
                    else
                        next = bads(bads ~= next);
                        choice = find(~ismissing(hands(:, next)), 1);
                    end
                else
                    handscores(stratflag) = handscores(stratflag)-100*flag;
                    if max(diff(handscores(~isnan(handscores)))) > 0.21
                        isgood(next) = 0.05;
                    end
                    next = find(handscores == max(handscores));
                    choice = find(~ismissing(hands(:, next)), 1);
                end
            elseif any(next == bads)
                if A(3,next) && max(diff(handscores(~isnan(handscores)))) > 0.21
                    next = find(handscores == min(handscores));
                    choice = find(~ismissing(hands(:, next)), 1);
                else
                    stratflag = next;
                    next = find(handscores == min(handscores));
                    choice = find(~ismissing(hands(:, next)), 1);
                end
            else
                if max(diff(handscores(~isnan(handscores)))) > 0.21
                    isgood(next) = 0.05;
                end
                next = find(handscores == max(handscores));
                choice = find(~ismissing(hands(:, next)), 1);
            end
        else
            next = find(~isnan(handscores));
            next = next(randi(length(next)));
            choice = find(~ismissing(hands(:, next)), 1);
        end
        hands(choice, next) = missing;
        if ~any(hands == "cthulhu", 'all')
            nummoves = ii*p-p+jj;
            stats = {nummoves, "b", num2str(a)};
            return
        elseif sum(hands == "rune", 'all') <= a
            nummoves = ii*p-p+jj;
            stats = {nummoves, "g", num2str(a)};
            return
        end
    end
    deck = hands(~ismissing(hands));
end
nummoves = ii*p-p+jj;
stats = {nummoves, "e", num2str(a)};
end