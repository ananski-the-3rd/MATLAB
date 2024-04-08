function best_strat = optimStats(model, start_stats, max_stats)
%OPTIMSTATS searches for optimal stat investment in a game that will
%maximize a skill.
%
%Input Arguments:
%   MODEL: a handle to a function that models the total effct of several
%   related skills. e.g. if initial HP is 50, and each skill point
%   increases HP by 5, while you can also invest skill points in DODGE to
%   increase dodge change by 2%, effective HP is: (5*HP +
%   50)/(1-2*DODGE/100). Therefore the model can be: model = @(hp, dodge)
%   (5*hp + 50)/(1-2*dodge/100).
%
%   START_STATS: a vector containing the starting value of each stat in
%   MODEL. If starting stats are all equal, START_STATS may be a scalar.
%
%   MAX_STATS: a vector containing the maximum value of each stat in MODEL.
%   If maximum stats are all equal, MAX_STATS may be a scalar.
%
%   BEST_STRAT = OPTIMSTATS(MODEL, START_STATS, MAX_STATS)
%
%   Anan Yablonko, 2023
arguments
model {mustBeA(model, 'function_handle')} = @(l, d) 250*(l+10)/(50-d);
start_stats {mustBeNumeric} = [0, 0];
max_stats {mustBeNumeric} = [99, 25];
end

n_stats = nargin(model);
loop_start = sum(start_stats);
loop_end = sum(max_stats);
best_strat = zeros(loop_end - loop_start + 1, n_stats);


% initialize Aeq (Aeq*x = beq)
% make sure that the number of stats we can invest is fixed (Aeq*x = beq)
% which in our case is equivalent to sum(temp) = stat_sum in fmincon below
Aeq = ones(1, n_stats);
% initialize lower and upper bounds on the solution
lb = zeros(n_stats, 1);
ub = zeros(n_stats, 1);
opts = optimoptions('fmincon', 'Display', 'none');

% initialize lower and upper bounds on the solution
lb(:) = start_stats;
ub(:) = max_stats;

for stat_sum = loop_start:loop_end
    x0 = repmat(stat_sum / n_stats, n_stats, 1);
    x0 = roundKeepSum(x0, stat_sum);
    
    % If we cannot reset the skills after every levelup, we return the best
    % short-term choice for each level.

    temp = fmincon( ...
        @(x) wrapperFunc(model, x), x0, [], [], Aeq, stat_sum, lb, ub, ...
        [], opts);
    temp = roundKeepSum(temp, stat_sum);
    best_strat(stat_sum - loop_start + 1, :) = temp;
end

    function out = wrapperFunc(f, vec_input)
        % converting a normal function f to reciprocal, and to a format
        % that the minimization function can work with.
        c_inputs = num2cell(vec_input);
        out = 1/f(c_inputs{:}); % maximization!
    end

    function v = roundKeepSum(x, sum_x)
        [~, i_sorted] = sort(x, 'descend');
        v = round(x);
        if sum_x > sum(v)
            idxs = i_sorted(1:sum_x-sum(v));
            v(idxs) = v(idxs) + 1;
        elseif sum_x < sum(v)
            idxs = i_sorted(end - sum(v) + sum_x + 1:end);
            v(idxs) = v(idxs) - 1;
        end
    end
end