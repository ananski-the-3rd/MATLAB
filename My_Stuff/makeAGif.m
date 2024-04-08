d = dir(fullfile('C:\Users\anan_\Desktop\הזמנה עלמות', '*.png'));
I = uint8(zeros(700,700,3,5));
V = VideoWriter(fullfile(getDesktop, 'Alamot.mp4'), 'MPEG-4');
n = 10; % frames per sec
V.FrameRate = n*0.91;
for ii = 1:length(d)
    I(:, :, :, ii) = imread(fullfile(d(ii).folder, d(ii).name));
end
I = repelem(I, 1, 1, 1, n);
open(V)
writeVideo(V, I);
close(V);