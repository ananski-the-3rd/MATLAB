%GOL
%%
n = 1e2; % world size
B = randi([0,1], n); % board in generation zero
max = 1e3;
%%
cla
close all
figure("WindowStyle","docked");

subplot(1,2,1)
I = image(B, 'CDataMapping','scaled');
colormap gray
subplot(1,2,2)
P = plot(sum(B, 'all'), 'r', 'LineWidth',2.5);

for ii = 1:max
    [B, flag] = next_gen(B);
    nalive = sum(B, 'all');

    if nalive == 0 || flag
        disp('all dead or unmoving')
        return
    end
    %% This bit is for fun, arraypat is an unrelated function I made :)
%     if ii > 100
%         for jj = 1:floor(ii/50)-1
%             if length(arraypat(P.YData(end-50*jj:end), P.YData(end-jj:end))) > 50
%                 disp('probably ocillating')
%                 return
%             end
%         end
%     end

    I.CData = B;
    P.YData = [P.YData, nalive];
    drawnow
end
disp('done in max moves')

function [B1, flag] = next_gen(B0)
nei = [1,1,1;1,0,1;1,1,1];
B_nei = conv2(B0, nei, 'same');
alive = (B_nei == 2 & B0) | B_nei == 3;
B1 = zeros(size(B0));
B1(alive) = 1;
if isequal(B0, B1)
    flag = 1;
else
    flag = 0;
end
end