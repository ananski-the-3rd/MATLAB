function brk2s = bracketing(regex_vec, options1, options2)
arguments
    regex_vec {mustBeText}
    options1 (1, :) char {mustBeMember(options1, {'out_in', 'in_out', 'lin_sort', 'lin_rev'})}= 'lin_rev'
    options2 (1, :) char {mustBeMember(options2, {'levels', 'simple'})} = 'levels'

end
% This function takes a string array (that came from a regexed char vector)
% and finds bracket pairs

brackets = [regex_vec == '('; regex_vec == ')'];
if ~any(brackets, "all")
    brk2s = [];
    return
end
no_b = 0.5*sum(brackets, "all");
brk2s = zeros(no_b, 3);
closing = find(brackets(2,:));
for i1 = 1:no_b
    my_range = brackets(1, 1:closing(i1)-1);
    my_level = sum(my_range);
    opening = find(my_range, 1, "last");
    brackets(1, opening) = 0;
    brk2s(i1, :) = [opening, closing(i1), my_level];
end
switch options1
    case 'lin_rev'
        
    case 'out_in'
        brk2s = sortrows(brk2s, 3);
    case 'in_out'
        brk2s = flipud(sortrows(brk2s, 3));
    case 'lin_sort'
        brk2s = sortrows(brk2s, 1);
    otherwise
        error('options1 must be ''out_in'', ''in_out'', ''lin_sort'' or ''lin_rev''')
end
if strcmp(options2, 'simple')
    brk2s(:, 3) = [];
elseif ~strcmp(options2, 'levels')
    error('options2 must be ''levels'' or ''simple''')
end

end
