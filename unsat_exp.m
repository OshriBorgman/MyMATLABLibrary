%% Calculate parameters

% % The average grain diameter
% d_avg = 0.59e-3; % [m] % For Satoshi's sample
% % d_avg = 0.83e-3; % [m] % Quino's cell

% The average pore size
lambda = 0.71e-3; % [m]

% Porosity
phi = 0.39; % For Satoshi's sample
% phi = 0.71; % Quino's cell

% Flow rate
q = [1e-11 5e-11 1e-10]; % [m^3/s];

% The flow rates in mul/hr:
q_mul_hr = 3600e9.*q; % [mul/hr]

% Permeability (after Pinela et al. 2005, eq 6)
a1 = 1e-5;
a2 = 11.09;
k_star = a1*exp(a2*phi);
% k = k_star*d_avg^2; % [m^2]
k = k_star*lambda^2; % [m^2]

% theta = (0.89*phi^3)*(1+(1-phi)^2)/(phi+(1-phi)^2+(1-phi)^3);
% k = phi^3/(36*theta*(1-phi)^2)*d_avg^2;

% The liquid viscosity
mu = 3.72e-2; % [kg/(ms)]

% The cross-section area is calculated from the cell width, aperture and
% porosity
W = 0.05; % [m]
b = 0.001;% [m]
t0ImgRatio = W*b*phi; % [m^2]

% The surface tension, from Jimenez-Martinez et al. 2017
gamma = 6.914e-2; % [N/m]


% Calculate the capillary number
Ca = (q.*mu*lambda^2)/(t0ImgRatio*k*gamma)


Q = Ca.*(gamma*k*t0ImgRatio)/(mu*lambda^2)

%% For Quino's cell

% The average pore size
lambda = 1.85e-3; % [m]

% Porosity
phi = 0.71; % Quino's cell

% Permeability (after Pinela et al. 2005, eq 6)
a1 = 3e-6;
a2 = 13.26;
k_star = a1*exp(a2*phi);
% k = k_star*d_avg^2; % [m^2]
k = k_star*lambda^2; % [m^2]

% theta = (0.89*phi^3)*(1+(1-phi)^2)/(phi+(1-phi)^2+(1-phi)^3);
% k = phi^3/(36*theta*(1-phi)^2)*d_avg^2;

% The liquid viscosity
mu = 3.72e-2; % [kg/(ms)]

% The cross-section area is calculated from the cell width, aperture and
% porosity
W = 0.087; % [m]
b = 0.0005;% [m]
t0ImgRatio = W*b*phi; % [m^2]

% The surface tension, from Jimenez-Martinez et al. 2017
gamma = 6.914e-2; % [N/m]


% % Calculate the capillary number
% Ca = (q.*mu*lambda^2)/(A*k*gamma)

Ca = 3e-5;

Q = Ca.*(gamma*k*t0ImgRatio)/(mu*lambda^2)

% The flow rates in mul/hr:
Q_mul_hr = 3600e9.*Q; % [mul/hr]

%% Calculate Pe
% The diffusion coefficient of Fluorescein [Jimenenz-Martinez et al. 2017]:
Dm = 1.049e-4; %[mm^2 s^-1
% The flow rate:
Q = 60/60; %[mm^3/s] [mul/s] 
% The porosity calculate from the image
phi = 0.55;
% The average pore size in mm, calculated from the analysis of the sample
% design
lambda = 0.16;
% Pore space aperture (pillar height)
b = 1; % [mm]
% Pore space width
w = 50; %[mm]
% The cross-section area of the cell
A = b*w;
% The average pore velocity
v = Q/(A*phi);
% The Peclet number
Pe = lambda*v/Dm;

%% Load the reference image and obtain the grain mask

% open the reference image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose reference image');

imgNameRef = imread(fullfile(filePath, fileName));

% Image name
imgCharNameRef = fileName;

% Plot the original
figure;
imagesc(imgNameRef); 
axis equal tight
title(['Reference intensity ' imgCharNameRef], 'Interpreter', 'none')

% Use an addaptive filter to get the grain mask
imgRefAdaptThresh1 = adaptthresh(imgNameRef, 'Neighborhoodsize', 35);
imgRefAdaptThresh2 = imbinarize(imgNameRef, imgRefAdaptThresh1);
imgRefAdaptThresh3 = ~imgRefAdaptThresh2;

figure;
imagesc(imgRefAdaptThresh3); 
axis equal tight
title(['Reference intensity thresholded' imgCharNameRef], 'Interpreter', 'none')

% Define the grains radius range in two parts
radRange1 = [10 25];
radRange2 = [25 40];
[centers1, radii1] = imfindcircles(imgRefAdaptThresh3, radRange1);
[centers2, radii2] = imfindcircles(imgRefAdaptThresh3, radRange2);
% Combine them together
centers = [centers1; centers2];
radii = [radii1; radii2];


grainMask = ones(size(imgNameRef));
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
% for i = 1:length(radii)
% rectangle('Position', [centers(i,1)-radii(i) centers(i,2)-radii(i) ...
%     2*radii(i) 2*radii(i)], 'Curvature', [1 1], 'EdgeColor', 'none', ...
%     'FaceColor', ones(1,3).*0.5)
% end
axis equal tight

%% Calculate saturation degree

% open the reference image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose reference image');

imgNameRef = imread(fullfile(filePath, fileName));

% Image name
imgCharNameRef = fileName;

% % Plot the original
% figure;
% imagesc(imgNameRef); 
% axis equal tight
% title(['Reference intensity ' imgCharNameRef], 'Interpreter', 'none')


% open the current image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose image for saturation calculation');

imgVarName = imread(fullfile(filePath, fileName));

% Image name
imgCharName = fileName;

% Limit the image range
% imgRange = {':', ':'};
imgRange = {470:2330, 100:3900};
imgVarNameTrim = imgVarName(imgRange{1}, imgRange{2});
imgNameRefTrim = imgNameRef(imgRange{1}, imgRange{2});
grainMaskTrim = grainMask(imgRange{1}, imgRange{2});

% plot the image 
figure; 
subplot(2, 3, 2)
imagesc(imgVarNameTrim);
axis equal tight
title(['image ' imgCharName])

% Show the reference
subplot(2, 3, 1)
imagesc(imgNameRefTrim);
axis equal tight
title(['Reference intensity ' imgCharNameRef], 'Interpreter', 'none')

% plot the image normalized by the reference and remove the grains
normImg = double(imgVarNameTrim)./double(imgNameRefTrim);
normImg(~grainMaskTrim) = 0;
subplot(2, 3, 3)
imagesc(normImg);
axis equal tight
title(['image ' imgCharName ' normalized by reference image ' imgCharNameRef], ...
    'Interpreter', 'none')

% Define the liquid saturation color threshold for the normalized image
colThresh = 0.8;

% Plot the image of the saturated part only, based on the normalized image
subplot(2, 3, 4)
imgVarThresh = normImg.*(normImg>colThresh);
imagesc(imgVarThresh); 
axis equal tight
title(['image ' imgCharName ' threshold = ' num2str(colThresh, '%2.4g')])


% Plot the water content profile
subplot(2, 3, 5)
plot(sum((normImg>colThresh), 1)./sum(grainMaskTrim, 1))
title({['longitudinal saturation ' imgCharName ' threshold = ' num2str(colThresh, '%2.4g')];...
    ['Overall saturation ' num2str(sum(normImg(:)>colThresh)/sum(grainMaskTrim(:)), '%2.4f')]})


% plot the image difference from the reference
subplot(2, 3, 6)
imagesc(double(imgVarNameTrim)-double(imgNameRefTrim));
axis equal tight
title(['image ' imgCharName ' difference reference image ' imgCharNameRef], ...
    'Interpreter', 'none')

%%%%%%%%%%%%%%%%%
% % Plot the image of the AIR part only, based on the normalized image
% subplot(2, 3, 4)
% imgVarThresh = normImg.*(normImg<colThresh);
% imagesc(imgVarThresh); 
% axis equal tight
% title(['image ' imgCharName ' threshold = ' num2str(colThresh, '%2.4g')])


% % Plot the AIR content profile
% subplot(2, 3, 5)
% plot(mean((normImg<colThresh), 1))
% title({['longitudinal liquid content ' imgCharName ' threshold = ' num2str(colThresh, '%2.4g')];...
%     ['Overall liquid content ' num2str(sum(sum((normImg>colThresh)))/numel(normImg), '%2.4f')]})

% % Define a color threshold for the non-normalized image
% colThresh = 0.2e4;

% % Plot the image of the saturated part only
% subplot(2, 3, 4)
% imgVarThresh = double(imgVarNameTrim).*(imgVarNameTrim>colThresh);
% imagesc(imgVarThresh); 
% axis equal tight
% title(['image ' imgCharName ' threshold = ' num2str(colThresh, '%2.4g')])

% % Plot the water content profile
% subplot(2, 3, 5)
% plot(mean((imgVarNameTrim>colThresh), 1))
% title({['longitudinal liquid content ' imgCharName ' threshold = ' num2str(colThresh, '%2.4g')];...
%     ['Overall liquid content ' num2str(sum(sum((imgVarNameTrim>colThresh)))/numel(normImg), '%2.4f')]})


%% Calculate saturation degree for a series of images
% open the reference image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose reference image');

imgNameRef = imread(fullfile(filePath, fileName));

% Image name
imgCharNameRef = fileName;

imgRange = {470:2330, 100:3900};
imgNameRefTrim = imgNameRef(imgRange{1}, imgRange{2});
grainMaskTrim = grainMask(imgRange{1}, imgRange{2});


% indicate the last image in the series
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose last image for saturation calculation');

lastImIdx = str2double(regexp(fileName, '\d*(?=.png)', 'match'));

figure(50);
clf
hold on
cmap = flipud(gray(lastImIdx));
% load the series of images and calculate the saturation profile
for i = 120:20:lastImIdx
imgVarName = imread(fullfile(filePath, [num2str(i, '%0.4d') '.png']));
imgVarNameTrim = imgVarName(imgRange{1}, imgRange{2});
normImg = double(imgVarNameTrim)./double(imgNameRefTrim);
normImg(~grainMaskTrim) = 0;
figure(50)
plot(sum((normImg>colThresh), 1)./sum(grainMaskTrim, 1), 'Color', cmap(i,:))

end

%% Display a single raw image

% open the current image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose image for display');

imgVarName = imread(fullfile(filePath, fileName));

% Image name
imgCharName = fileName;

% Limit the image range
imgRange = {':', ':'};
% imgRange = {400:2330, 100:3900};
imgVarNameTrim = imgVarName(imgRange{1}, imgRange{2});

% plot the image 
figure; 
imagesc(imgVarNameTrim);
axis equal tight
% caxis([0, 15e3])
caxis([0, 65e3])
title(['image ' imgCharName])

%% Compare between two raw images

% Limit the image range
% imgRange = {':', ':'};
% imgRange = {400:2330, 100:3900};
imgRange = {700:1500, 100:3900};

% Limit the color value
colLim = 20e3;

% open the first image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose first image for comparison');

imgVarName = imread(fullfile(filePath, fileName));

% Image name
imgCharName1 = fileName;

A = imgVarName(imgRange{1}, imgRange{2});

% plot the first image 
figure; 
imagesc(A);
axis equal tight
caxis([0, colLim])
title(['image ' imgCharName1])

% open the second image
[fileName, filePath] = uigetfile(fullfile(filePath, '\*.png'), 'Choose second image for comparison');

imgVarName = imread(fullfile(filePath, fileName));

% Image name
imgCharName2 = fileName;

B = imgVarName(imgRange{1}, imgRange{2});

% plot the first image 
figure; 
imagesc(B);
axis equal tight
caxis([0, colLim])
title(['image ' imgCharName2])

% Compare the images
figure; 
imagesc(B-A);
axis equal tight
caxis([0, colLim])
title(['image ' imgCharName2 ' - ' 'image ' imgCharName1])

%% Plot the t0 image and calculate the spatial variability

% open the image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose t0 image');

imgNamet0 = imread(fullfile(filePath, fileName));

% Image name
imgCharNamet0 = fileName;

% Limit the image range
imgRange = {200:1800, ':'};
% imgNamet0 = imgNamet0(imgRange{1}, imgRange{2});

% Plot the original
figure;
imagesc(imgNamet0); 
axis equal tight
title(['image ' imgCharNamet0], 'Interpreter', 'none')

% Plot the mean longitudinal intensity
meanLongIntens = mean(imgNamet0, 1);
figure;
plot(meanLongIntens)
title(['image ' imgCharNamet0 ' mean longitudinal intensity'], 'Interpreter', 'none')

% Calculate and plot the longitudinal standard deviation
stdLongIntens = std(double(imgNamet0)./(2^16-1), 1);
figure;
plot(stdLongIntens)
title(['image ' imgCharNamet0 ' longitudinal standard deviation'], 'Interpreter', 'none')

% Plot the mean transverse intensity
meanTransIntens = mean(imgNamet0, 2);
figure;
plot(meanTransIntens)
title(['image ' imgCharNamet0 ' mean transverse intensity'], 'Interpreter', 'none')

% To creat the grain mask:
% % 1. Threshold by the longitudinal variation in intensity, by creating a
% % matrix from the mean intensity
% colThreshField = repmat(meanLongIntens, size(imgNamet0,1), 1);
% figure; 
% imgt0ThreshField = imgNamet0.*uint16(imgNamet0>(colThreshField));
% imagesc(imgt0ThreshField); 
% axis equal tight
% title(['t_0 image threshold by the longitudinal average'])

% 2. Define the liquid saturation color threshold
colThresh = 15e3;

% Plot the image of the saturated part only
figure; 
imgt0ThreshVal = imgNamet0.*uint16(imgNamet0>(colThresh));
imagesc(imgt0ThreshVal); 
axis equal tight
title(['t_0 image threshold by constant value ' num2str(colThresh, '%2.1e')])

%% Normalize the images by t0

% Convert images to double
doubImgVar = double(imgVarThresh)./(2^16-1);
doubImgt0 = double(imgNamet0)./(2^16-1);

% Display the image divided by the t0 image
figure;
imagesc(doubImgVar./doubImgt0); 
axis equal tight
title(['image ' imgCharName ' normalized by t_0'])

%% Compare two t0 images

% open the second image
[fileName, filePath] = uigetfile('D:\Oshri\*.png', 'Choose a second t0 image');

imgNamet0_2 = imread(fullfile(filePath, fileName));

% Image name
imgCharNamet0_2 = fileName;

% Limit the image range
imgRange = {200:1800, ':'};
imgNamet0_2 = imgNamet0_2(imgRange{1}, imgRange{2});

% Plot the second image
figure;
imagesc(imgNamet0_2); 
axis equal tight
title(['image ' imgCharNamet0_2], 'Interpreter', 'none')


% Obtain and plot the ratio between the images
t0ImgRatio = double(imgNamet0)./double(imgNamet0_2);
figure;
imagesc(t0ImgRatio); 
axis equal tight
title('ratio between two t_0 images')

% Calculate the average ratio
avgt0ImgRat = mean(t0ImgRatio(:));


%% Normalize the images by a previous one

% open the second image
[fileName, filePath] = uigetfile('*.png', 'Choose a second t0 image');

imgVarName_2 = imread(fullfile(filePath, fileName));

% Image name
imgCharName_2 = fileName;

% Limit the image range
imgRange = {200:1800, ':'};
imgVarName_2 = imgVarName_2(imgRange{1}, imgRange{2});


% Convert images to double
doubImgVar = double(imgVarName)./(2^16-1);
doubImgVar2 = double(imgVarName_2)./(2^16-1);

% Display the image divided by the t0 image
figure;
imagesc(doubImgVar./doubImgVar2); 
axis equal tight
title(['image ' imgCharName ' normalized by t_0'])
% Change the color axis to emphasize the variation of intensity
caxis([0 1.5])




