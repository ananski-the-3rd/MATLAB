% clear; clc;
% NumofRun = 1;
% MaxRun = 40;
% while NumofRun<MaxRun
%     try
%     The_6174 % here put the program
%     catch
%         fprintf('Your program sucks!\n')
%     end
%     checkmore = input('Run Again? [Y/N]: ','s');
%     if strcmpi(checkmore, 'Y') || isempty(checkmore)
%         NumofRun = NumofRun + 1;
%     elseif strcmpi(checkmore, 'N')
%         break;
%     else
%         error('Non comprendo, abort! abort!');
%     end
% end

%%

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
    dis_re = re{ii};
    randwords = regexpgen(dis_re, 100);
end
%%
% bank = '{}()[]+?*|e,.\dw10-^:>';
% a = nmultichoosek(bank, 7);
% for ii = 1:7
%     all_to_try = nmultichoosek(bank, ii);
%     for jj = 1:length(all_to_try)
%         dis_re = all_to_try(jj, :);
%         randwords = regexpgen(dis_re, 15);
%     end
% end
% function combs = nmultichoosek(values, k)
% %// Return number of multisubsets or actual multisubsets.
% if numel(values)==1 
%     n = values;
%     combs = nchoosek(n+k-1,k);
% else
%     n = numel(values);
%     combs = bsxfun(@minus, nchoosek(1:n+k-1,k), 0:k-1);
%     combs = reshape(values(combs),[],k);
% end
% end
