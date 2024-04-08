% n = 6;
% gg = 0;
% ih = 0;
% ic = 1;
% C = cell(10, 1);
% while ih < 1e5
%     ih = ih + 1;
% 
%     perm_n = flipud(perms(1:n));
%     saved_perms = [];
% 
%     pairs = nchoosek(1:n, 2)';
%     l_nck = 0.5*n*(n-1);
% 
%     next = 1;
%     k = 1;
%     while ~isempty(perm_n)
%         perm = perm_n(next, :);
%         dist = swapDistance(perm, perm_n);
%         saved_perms = [saved_perms; perm];
%         mask = dist < 3;
%         perm_n(mask, :) = [];
%         dist(mask) = [];
%         %     if sum(saved_perms(:, 1) == k) == 5
%         %         mask = perm_n(:, 1) == k;
%         %         perm_n(mask, :) = [];
%         %         dist(mask) = [];
%         %         k = k + 1;
%         %     end
%         if isempty(perm_n)
%             break
%         end
%         p = find(dist == min(dist));
%         next = p(randi([1, length(p)]));
%     end
%     gg = size(saved_perms, 1);
%     if gg >= 26
%         C{ic} = sortrows(saved_perms);
%         ic = ic + 1;
%         if length(C) > 10
%             break
%         end
%     end
% end
% 
% saved_perms = sortrows(saved_perms);
% D = dictionary(mat2cell(saved_perms, ones(1, gg)), [1:gg]');

load('perm_dict.mat');
M = cell2mat(D.keys);

