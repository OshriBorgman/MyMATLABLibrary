%% Load the reference image and obtain the grain mask

% open the reference image
[fileName, filePath] = uigetfile('E:\*.png', 'Choose reference image');
imgNameRef = double(fliplr(imread(fullfile(filePath, fileName))))/(2^16-1);

% [fileName, filePath] = uigetfile('E:\*.tiff', 'Choose reference image');
% imgNameRef = imread(fullfile(filePath, fileName), 'tif');

% Image name
imgCharNameRef = fileName;

% Plot the original
figure;
imagesc(imgNameRef); 
axis equal tight
title(['Reference intensity ' imgCharNameRef], 'Interpreter', 'none')

% Use an addaptive filter to get the grain mask
imgRefAdaptThresh1 = adaptthresh(imgNameRef, 'Neighborhoodsize', 35);
% imgRefAdaptThresh1 = graythresh(imgNameRef);
imgRefAdaptThresh2 = imbinarize(imgNameRef, imgRefAdaptThresh1);
imgRefAdaptThresh3 = ~imgRefAdaptThresh2;

figure;
imagesc(imgRefAdaptThresh3); 
axis equal tight
title(['Reference intensity thresholded ' imgCharNameRef], 'Interpreter', 'none')

% % % Define the grains radius range in two parts
% % radRange1 = [10 25];
% % radRange2 = [25 40];
% Define the grains radius range in two parts for the first Cargese experiment
radRange1 = [15 30];
radRange2 = [30 50];
[centers1, radii1] = imfindcircles(imgRefAdaptThresh3, radRange1);
[centers2, radii2] = imfindcircles(imgRefAdaptThresh3, radRange2);
% Combine them together
centers = [centers1; centers2];
radii = [radii1; radii2];

% % Increase the radii of the circles to improve the mask and remove
% % artifacts
% radii = radii+1.5;

% Clear pixels which are not within the grain radii
grainMask = true(size(imgNameRef));
[y, x] = find(grainMask);
Xpixels = [x, y];
treeMod = KDTreeSearcher(Xpixels);
for i = 1:length(radii)
Idx = rangesearch(treeMod, centers(i,:), radii(i));
grainMask(Idx{:}) = false;
end

% Plot the resulting grain mask
figure;
imagesc(grainMask)
axis equal tight

% Plot the original
figure;
imagesc(imgNameRef); 
% Overlay the identified grains as circles
hold on
ax = gca;
for i = 1:length(radii)
rectangle('Position', [centers(i,1)-radii(i) centers(i,2)-radii(i) ...
    2*radii(i) 2*radii(i)], 'Curvature', [1 1], 'EdgeColor', 'none', ...
    'FaceColor', ones(1,3).*0.5)
end
axis equal tight
title(['Reference intensity + grains' imgCharNameRef], 'Interpreter', 'none')


%%

% Find bubbles with radii smaller than the grains
radRangeBub1 = [5 10];
radRangeBub2 = [15 20];
[centersBub1, radiiBub1] = imfindcircles(imgRefAdaptThresh3, radRangeBub1);
[centersBub2, radiiBub2] = imfindcircles(imgRefAdaptThresh3, radRangeBub2);
% Combine them together
centersBub = [centersBub1; centersBub2];
radiiBub = [radiiBub1; radiiBub2];

grainMask2 = grainMask;

% Restore the bubble pixels to the porous medium
for i = 1:length(radiiBub)
Idx = rangesearch(treeMod, centersBub(i,:), radiiBub(i));
grainMask2(Idx{:}) = true;
end

% Plot the resulting grain mask
figure;
imagesc(grainMask2)
axis equal tight

% Plot the difference
figure;
imagesc(grainMask2+2*grainMask)
axis equal tight


%%
AA = imgNameRef;
AA(~grainMask) = 0;
PlotFieldImage(AA);
BB = abs(gradient(double(AA)));
% PlotFieldImage(BB);
AA2 = AA;
AA2(AA==max(AA(:))) = 0;
PlotFieldImage(AA2);