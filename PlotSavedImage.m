function [imH] = PlotSavedImage

[outImgName, outImgPath] = uigetfile(fullfile('', '*.png'));

img = imread(fullfile(outImgPath, outImgName));

[imH] = PlotFieldImage(img);

title(outImgName, 'Interpreter', 'none')

end