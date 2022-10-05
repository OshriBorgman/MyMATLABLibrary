%% Load the reference image and obtain the sizes of holes in the mask

% open the reference image
[fileName, filePath] = uigetfile('*.png', 'Choose reference image');

imgRef = double(imread(fullfile(filePath, fileName)));

% Image name
imgCharNameRef = fileName;

% Plot the original
figure;
imagesc(imgRef); 
axis equal tight
title(['Reference intensity ' imgCharNameRef], 'Interpreter', 'none')

%% Filter the image and normalize
% Filter
n = 500;
imgFilt = imfilter(imgRef,ones(n)./(n^2));
figure;
imagesc(imgFilt); 
axis equal tight
title(['Filtered ' imgCharNameRef], 'Interpreter', 'none')

% Calculate the normalized image
imgNorm = imgRef./imgFilt;
figure;
imagesc(imgNorm); 
axis equal tight
title(['Normalized ' imgCharNameRef], 'Interpreter', 'none')

figure;
histogram(imgNorm); 
title(['Normalized ' imgCharNameRef], 'Interpreter', 'none')
%%
% Choose a sub-region in the middle of the image, as x and y
% subReg = {1000:3000, 300:2300};
% subReg = {':', 60:2500};
subReg = {1:3900, 100:2550};
% subReg = {277:3297, 1283:2053};
subImg = imgNorm(subReg{2}, subReg{1});

% % Use an addaptive filter to get the grain mask
% imgRefAdaptThresh1 = adaptthresh(imgNameRef, 'Neighborhoodsize', 35);
% To obtain the holes in a laser-cut mask
imgRefAdaptThresh1 = graythresh(subImg);
imgRefAdaptThresh2 = imbinarize(subImg, imgRefAdaptThresh1);
imgRefAdaptThresh3 = ~imgRefAdaptThresh2;

figure;
imagesc(imgRefAdaptThresh3); 
axis equal tight
title(['Reference intensity thresholded' imgCharNameRef], 'Interpreter', 'none')

% Define the grains radius range in two parts
clear radii
radRange1 = [10 25];
radRange2 = [25 40];
[centers1, radii1] = imfindcircles(imgRefAdaptThresh3, radRange1);
[centers2, radii2] = imfindcircles(imgRefAdaptThresh3, radRange2);
% Combine them together
centers = [centers1; centers2];
radii = [radii1; radii2];


grainMask = ones(size(subImg));
[y, x] = find(grainMask);
Xpixels = [x, y];
treeMod = KDTreeSearcher(Xpixels);
for i = 1:length(radii)
Idx = rangesearch(treeMod, centers(i,:), radii(i));
grainMask(Idx{:}) = 0;
end

% Plot the resulting grain mask
figure;
imagesc(grainMask)
% Overlay the identified grains as circles
hold on
ax = gca;
for i = 1:length(radii)
rectangle('Position', [centers(i,1)-radii(i) centers(i,2)-radii(i) ...
    2*radii(i) 2*radii(i)], 'Curvature', [1 1], 'EdgeColor', 'none', ...
    'FaceColor', ones(1,3).*0.5)
end
axis equal tight

%% Plot the grains over the original image
% Increase the radii if needed according to the image
radii2 = radii+2;

figure;
% % For the normalized image
% imagesc(imgNorm(subReg{2}, subReg{1})); 
% For the original reference image
imagesc(imgRef(subReg{2}, subReg{1})); 
title('Reference intensity with plotted holes')
hold on
ax = gca;
for i = 1:length(radii2)
rectangle('Position', [centers(i,1)-radii2(i) centers(i,2)-radii2(i) ...
    2*radii2(i) 2*radii2(i)], 'Curvature', [1 1], 'EdgeColor', 'none', ...
    'FaceColor', ones(1,3).*0.5)
end
axis equal tight

%% Analyze hole size statistics
% Set the image length scale in mm
lenScale = 60;
% Set the number of pixels
pixNum = length(subReg{2});
% Calculate the pixel length in mm
pixLen = lenScale/pixNum;

% Calculate the average radii of the circles
radAvg = mean(radii2)*pixLen
% Calculate radii std of the circles
radSTD = std(radii2)*pixLen

% Plot the histogram of circle radii
figure;
hold on
histogram(radii2*pixLen, 'BinWidth', 0.005, 'Normalization', 'pdf')
xlabel('hole radius [mm]')
ylabel('pdf')
title('mask')

%% Analyze statistics of original design
% Plot the histogram of circle radii
% figure;
histogram(SimDataSave(3).DGrains/2, 'BinWidth', 0.005, 'Normalization', 'pdf')
xlabel('hole radius [mm]')
ylabel('pdf')
title('design')
