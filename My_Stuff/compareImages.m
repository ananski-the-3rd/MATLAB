function compareImages(I1, I2, cmap)
%COMPAREIMAGES displayes two images side by side
% COMPAREIMAGES(I1, I2, cmap) displays the two images I1 and I2 with the
% colormap CMAP.
fname = 'LAdugoDV';
a = findall(groot, 'Name', fname);
delete(a);
F = figure('Name', fname);
subplot(1,2,1); imagesc(I1); axis image
subplot(1,2,2); imagesc(I2); axis image
if nargin > 2
    colormap(cmap);
end