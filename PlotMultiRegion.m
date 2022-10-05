function [labelImg, fh] = PlotMultiRegion(inputImg, varargin)
% Plot individual clusters in a binary image in different colors

if length(varargin)==0
    xCoor = size(inputImg, 2);
    yCoor = size(inputImg, 1);
    imgName = '';
elseif length(varargin)==1
    xCoor = size(inputImg, 2);
    yCoor = size(inputImg, 1);
    imgName = varargin{1};
elseif length(varargin)==2
    xCoor = varargin{2}(1);
    yCoor = varargin{2}(2);
    imgName = varargin{1};
end

labelImg = bwlabel(inputImg);

figure;
ax = gca;
fh = imagesc(xCoor, yCoor, labelImg);
axis equal tight
ax.Title.String = [imgName ' labeled clusters'];
ax.Title.Interpreter = "none";
ax.XLabel.String = 'x [mm]';
ax.YLabel.String = 'y [mm]';
cmap = colormap(hsv(length(unique(labelImg))));
[a, b] = size(cmap);
c_vec = randperm(a);
cmap2 = cmap(c_vec,:);
cmap2(1,:) = [0 0 0];
colormap(cmap2)

end
