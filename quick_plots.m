%% Plot the concentration profile
% For a specific nPoint
figure; 
plot(CLongProf(nPoint).xDataMeas, CLongProf(nPoint).yDataMeas./CLongProf(nPoint).Cmax, 'o', ...
    'DisplayName', 'Measured')
hold on
plot(CLongProf(nPoint).xDataFit, CLongProf(nPoint).yDataFit./CLongProf(nPoint).Cmax, '--', ...
    'DisplayName', 'Fitted')
xlabel('x position [mm]')
ylabel('normalized concentration')
legend('show')

%% Plot histogram of the gradients
% For a specific nPoint
G11 = G;
% G11(G<8000) = 0;
% G11(G>1e5) = 0;
X = nonzeros(G11(mixZone));
figure; 
[N,edges] = histcounts(X);
plot(edges(2:end)-diff(edges), N, 'o')
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';

%%

mean(nonzeros(G))
mean(nonzeros(G11))

%% Clean the gradient image

% Threshold the gradient image to remove high intensity noise
GThresh = G;
idx = find(N>1e2, 1, 'last');
GThresh(G>edges(idx)) = 0;

% Threshold to remove some small values
GThresh2 = GThresh>(0.5*mean(nonzeros(GThresh)));

% Set the parameters for the morphological functions
rEr = 2;
nEr = 2;
nHood = 2;

% % Erode and dilate the gradient structures to remove small elements and
% % enhance the actual gradient bands
% Use a disk element
% GOpen = imopen(GThresh2, strel('disk',rEr,nEr));
% Use a square element
% GOpen = imopen(GThresh2, strel('square',rEr));
% Use line elements at different orientations
GOpen = imopen(GThresh2, strel('line',rEr,90));
GOpen = imopen(GOpen, strel('line',rEr,0));
GOpen = imopen(GOpen, strel('line',rEr,45));

% Remove the bands which touch the grains of the grain mask

mean(nonzeros(G))
mean(nonzeros(G.*GOpen))
PlotFieldImage(G.*GOpen);
caxis([5000 30000])

X = nonzeros(G.*GOpen);
figure; 
[N,edges] = histcounts(X);
plot(edges(2:end)-diff(edges), N, 'o')
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';

%% Filter the gradient image
nFiltGrad = 3;
GFilt = imfilter(G.*Gr, ones(nFiltGrad)./(nFiltGrad^2));
PlotFieldImage(GFilt);
mean(nonzeros(GFilt))

%%

saveMeanGrad2 = [];

for frIdx = imgIdxList
    
    nPoint = find(imgIdxList==frIdx);
    
    [C, G, gradBinCount, gradPDFEdges, saveMeanGrad, mixZone, VmWidth, VmArea] = ImageConcGradUnsat...
        (CMax, CMin, nPoint, unsatMaskImg, grainMaskDil2, analyzImgsFolderConc, analyzImgsFolderGrad, ...
        mixZoneMaxC, mixZoneMinC, gradBinCount, gradPDFEdges, saveMeanGrad, conImgFiles(frIdx).name, ...
        VmWidth, VmArea, pixLen);


G = G.*mixZone.*grainMaskDil2;
% Threshold the gradient image to remove high intensity noise
GThresh = G;
idx = find(N>1e2, 1, 'last');
GThresh(G>edges(idx)) = 0;

% Threshold to remove some small values
GThresh2 = GThresh>(0.5*mean(nonzeros(GThresh)));

% Set the parameters for the morphological functions
rEr = 4;
nEr = 4;
nHood = 2;

% % Erode and dilate the gradient structures to remove small elements and
% % enhance the actual gradient bands
% Use a disk element
% GOpen = imopen(GThresh2, strel('disk',rEr,nEr));
% Use a square element
% GOpen = imopen(GThresh2, strel('square',rEr));
% Use line elements at different orientations
GOpen = imopen(GThresh2, strel('line',rEr,90));
GOpen = imopen(GOpen, strel('line',rEr,0));
GOpen = imopen(GOpen, strel('line',rEr,45));

saveMeanGrad2(nPoint) = mean(nonzeros(G.*GOpen));

end

figure; 
plot([1:length(saveMeanGrad2)]*delT, ...
    saveMeanGrad2./CMax.*(mean(SampleDataStruct.throatHalfLength)*2), '^')
xlabel('t [s]')
ylabel('$\nabla c / [c_{max} / a]$')
set(gca, 'XScale', 'log', 'YScale', 'log')

%%

% Obtain the properties of the non-aqueous phase
gradImgBWLabel = bwlabel(GOpen);
gradImgBWProps = regionprops(gradImgBWLabel, "all");

% Set the x and y coordinates
xCoor = [1:size(GOpen, 2)].*pixLen;
yCoor = [1:size(GOpen, 1)].*pixLen;

% Plot the regions
figure;
ax = gca;
imagesc(xCoor, yCoor, gradImgBWLabel)
axis equal tight
ax.Title.String = 'Gradient labeled clusters';
ax.Title.Interpreter = "none";
ax.XLabel.String = 'x [mm]';
ax.YLabel.String = 'y [mm]';
cmap = colormap(hsv(length(gradImgBWProps)));
[a, b] = size(cmap);
c_vec = randperm(a);
cmap2 = cmap(c_vec,:);
cmap2(1,:) = [0 0 0];
colormap(cmap2)

figure;
histogram([gradImgBWProps.Orientation])

% Plot the regions without certain clusters
excludeClusters = find(abs([gradImgBWProps.Orientation])>45);
gradImgBWLabel2 = gradImgBWLabel;
gradImgBWLabel2(ismember(gradImgBWLabel,excludeClusters)) = 0;
figure;
ax = gca;
imagesc(xCoor, yCoor, gradImgBWLabel2)
axis equal tight
ax.Title.String = 'Gradient labeled clusters';
ax.Title.Interpreter = "none";
ax.XLabel.String = 'x [mm]';
ax.YLabel.String = 'y [mm]';
cmap = colormap(hsv(length(gradImgBWProps)));
[a, b] = size(cmap);
c_vec = randperm(a);
cmap2 = cmap(c_vec,:);
cmap2(1,:) = [0 0 0];
colormap(cmap2)

PlotFieldImage(G.*logical(gradImgBWLabel2));
caxis([5000 30000])

mean(nonzeros(G.*logical(gradImgBWLabel2)))

%%

saveMeanGrad4 = [];

for frIdx = imgIdxList
    
    nPoint = find(imgIdxList==frIdx);
    
    [C, G, gradBinCount, gradPDFEdges, saveMeanGrad, mixZone, VmWidth, VmArea] = ImageConcGradUnsat...
        (CMax, CMin, nPoint, unsatMaskImg, grainMaskDil2, analyzImgsFolderConc, analyzImgsFolderGrad, ...
        mixZoneMaxC, mixZoneMinC, gradBinCount, gradPDFEdges, saveMeanGrad, conImgFiles(frIdx).name, ...
        VmWidth, VmArea, pixLen);


G = G.*mixZone.*grainMaskDil2;
% Threshold the gradient image to remove high intensity noise
GThresh = G;
X = nonzeros(G);
[N,edges] = histcounts(X);
idx = find(N>1e2, 1, 'last');
GThresh(G>edges(idx)) = 0;

% Threshold to remove some small values
GThresh2 = GThresh>(1*mean(nonzeros(GThresh)));

% Set the parameters for the morphological functions
rEr = 2;
nEr = 2;
nHood = 2;

% % Erode and dilate the gradient structures to remove small elements and
% % enhance the actual gradient bands
% Use a disk element
% GOpen = imopen(GThresh2, strel('disk',rEr,nEr));
% Use a square element
% GOpen = imopen(GThresh2, strel('square',rEr));
% Use line elements at different orientations
GOpen = imopen(GThresh2, strel('line',rEr,90));
GOpen = imopen(GOpen, strel('line',rEr,0));
GOpen = imopen(GOpen, strel('line',rEr,45));

% Obtain the properties of the non-aqueous phase
gradImgBWLabel = bwlabel(GOpen);
gradImgBWProps = regionprops(gradImgBWLabel, "all");
% Plot the regions without certain clusters
excludeClusters = find(abs([gradImgBWProps.Orientation])>45);
gradImgBWLabel2 = gradImgBWLabel;
gradImgBWLabel2(ismember(gradImgBWLabel,excludeClusters)) = 0;

saveMeanGrad4(nPoint) = mean(G(logical(gradImgBWLabel2)));

end

figure; 
plot([1:length(saveMeanGrad4)]*delT, ...
    saveMeanGrad4./CMax.*(mean(SampleDataStruct.throatHalfLength)*2), '^')
xlabel('t [s]')
ylabel('$\nabla c / [c_{max} / a]$')
set(gca, 'XScale', 'log', 'YScale', 'log')

%%

% Load the 16 bit images
C16 = imread(fullfile(analyzImgsFolderConc, conImgFiles(frIdx).name));
G16 = imread(fullfile(analyzImgsFolderGrad, ['G' conImgFiles(frIdx).name(2:end)]));


% convert them back to double variables
G = double(G16)*CMax;
C = double(C16)/(2^16-1)*CMax;

[mixZoneTight] = ImageSubsetRegion(C, 0.05*(CMax-CMin)+CMin, 0.95*(CMax-CMin)+CMin);
% Define the mixing zone as a rectangle, defined by the extreme x-values of the
% tight mixing zone 
[y, mixZoneX] = find(mixZoneTight);
mixZoneXMax = max(mixZoneX);
mixZoneXMin = min(mixZoneX);
mixZone = false(size(mixZoneTight));
mixZone(:,mixZoneXMin:mixZoneXMax) = unsatMaskImg(:,mixZoneXMin:mixZoneXMax);

CMaxIm = C==CMax;
CMaxImDil = imdilate(CMaxIm, strel('disk',1,4));
G12 = G;
G12(CMaxImDil)=0;
PlotFieldImage(G12);
title('G(CMaxImDil)=0')
caxis([0 50000])
figure; histogram(nonzeros(G(:)))
set(gca, 'xscale', 'log', 'YScale', "log")
[h, b] = histcounts(nonzeros(G(:)));
figure; loglog(h, 'o')
[m,i] = min(h)
b(i)
G13 = G12;
G13((G13>b(i)==0));
PlotFieldImage(G13.*grainMaskDil, 'G13.*grainMaskDil');
caxis([0 b(i)])
figure; histogram(nonzeros(G13(grainMaskDil)))
set(gca, 'xscale', 'log', 'YScale', "log")
[h13, b13] = histcounts(nonzeros(G13(grainMaskDil)));
[m13,i13] = min(h13)
b13(i13)
G14 = G13;
G14(G13>b13(i13))=0;
PlotFieldImage(G14.*grainMaskDil.*mixZone);
caxis([0 b13(i13)])
figure; histogram(nonzeros(G14(grainMaskDil)))
set(gca, 'xscale', 'log', 'YScale', "log")
[h14, b14] = histcounts(nonzeros(G14(grainMaskDil)));
[m14,i14] = min(h14)
b14(i14)
G15 = imfilter(G14, ones(3)./(3^2));
PlotFieldImage(G15.*grainMaskDil.*mixZone);
caxis([0 b14(i14)])
mean(G15(grainMaskDil(mixZone)))
figure; histogram(nonzeros(G15(grainMaskDil)))

[H, edges] = histcounts(nonzeros(G15(grainMaskDil)));
xEd = cumsum(0+diff(edges));
figure; loglog(xEd, H, 'o')
G16 = G15;
G16(G15>4e4) = 0;
PlotFieldImage(G16.*grainMaskDil.*mixZone);

%%

G16 = G15.*grainMaskDil.*mixZone;
% Threshold to remove some small values
GThresh2 = G16>(0.5*mean(nonzeros(G16)));

% Set the parameters for the morphological functions
rEr = 1;
nEr = 1;
nHood = 2;

% % Erode and dilate the gradient structures to remove small elements and
% % enhance the actual gradient bands
% Use a disk element
GOpen = imopen(GThresh2, strel('disk',rEr,4));
% Use a square element
% GOpen = imopen(GThresh2, strel('square',rEr));
% % Use line elements at different orientations
% GOpen = imopen(GThresh2, strel('line',rEr,90));
% GOpen = imopen(GOpen, strel('line',rEr,0));
% GOpen = imopen(GOpen, strel('line',rEr,45));

% Obtain the properties of the non-aqueous phase
gradImgBWLabel = bwlabel(GOpen);
gradImgBWProps = regionprops(gradImgBWLabel, "Orientation", "Area");
% Remove small clusters
excludeClusters = find(abs([gradImgBWProps.Area])<20);
gradImgBWLabel2 = gradImgBWLabel;
gradImgBWLabel2(ismember(gradImgBWLabel,excludeClusters)) = 0;
% Remove clusters not oriented perpendicular to the flow direction
excludeClusters = find(abs([gradImgBWProps.Orientation])>45) ;
gradImgBWLabel3 = gradImgBWLabel2;
gradImgBWLabel3(ismember(gradImgBWLabel2,excludeClusters)) = 0;
% The final gradient mask
gradMask = logical(gradImgBWLabel3);

G17 = G16.*gradMask;
PlotFieldImage(G17);
mean(G17(grainMaskDil(mixZone)))

%%
% % find a model for the gradients' distribution

% The power law scale
a1 = 1e4;
% The power law slope
a2 = -1.5;
% The y-intersection of the first exponential cutoff
b1 = 1e6;
% The first exponential cutoff
b2 = 0.8e4;
% The y-intersection of the second exponential cutoff
c1 = 5e5;
% The second exponential cutoff
c2 = 5e4;
% The power law model 
x1 = logspace(3, 4, 1e2);
y1 = a1.*x1.^a2;
% The first exponential model 
x2 = logspace(2, 5.5, 1e2);
y2 = b1.*exp(-x2/b2);
% The second exponential model 
x3 = logspace(2, 5.5, 1e2);
y3 = c1.*exp(-x3/c2);

% The full model:
x = logspace(3, 5.5, 1e2);
y = a1.*x.^a2 .* (b1.*exp(-x/b2) + c1.*exp(-x/c2));

fmodel=@(x,p) p(1).*x.^a2 .* (b1.*exp(-x/b2) + c1.*exp(-x/c2));

error=@(p) (fmodel(xData,p)-yData)'*(fmodel(xData,p)-yData);

pfit = fminsearch(error,pguess);

plot(x,fmodel(x,pfit));

figure(1);
hold on
plot(x1, y1, '-k', 'DisplayName', 'power law')
% plot(x2, y2, '-b', 'DisplayName', 'first exponential')
% plot(x3, y3, '-r', 'DisplayName', 'second exponential')
legend('show')
set(gca, 'xscale', 'log', 'YScale', "log")

figure(10);
plot(x, y, '-k', 'DisplayName', 'full model')
legend('show')
set(gca, 'xscale', 'log', 'YScale', "log")


%%

data=nonzeros(G15(grainMaskDil));
edges = logspace(log10(min(data)),log10(max(data)),100);
H = histcounts(data,edges,'normalization','pdf');
xEd = (edges(2:end)+edges(1:end-1))/2;
figure;
plot(xEd, H, 'o');
set(gca, 'xscale', 'log', 'YScale', "log")
set(gca, 'XLim', [1e3 2e5])
hold on

xData = xEd(xEd>2e3);
yData = H(xEd>2e3);

xData(yData==0) = [];
yData(yData==0) = [];

% % One power law
% fmodel = @(x,p) p(1).*x.^p(2) .* (p(3).*exp(-x/p(4)) + p(5).*exp(-x/p(6)));
% p0 = [a1, a2, b1, b2, c1, c2];
% fmodel = @(x,p) x.^p(1) .* (p(2).*exp(-x/p(3)) + p(4).*exp(-x/p(5)));
% p0 = [a2, b1, b2, c1, c2];
% % Fix the power law exponent
% fmodel = @(x,p) x.^(-1.5).* (p(1).*exp(-x/p(2)) + p(3).*exp(-x/p(4)));
% p0 = [b1, 40e4, c1, c2];
% % two power laws
% fmodel = @(x,p) (p(1).*x.^p(2) + p(3).*x.^p(4)) .* exp(-x/p(5));
% p0 = [100, -1.5, 100, -2, b2];
% % One power law, three exponentials
fmodel = @(x,p) x.^p(1) .* (p(2).*exp(-x/p(3)) + p(4).*exp(x/p(5)) + p(6).*exp(-x/p(7)));
p0 = [-1.5, 1, 1e4, 1, 5e4, 1, 1e5];


error = @(p) (fmodel(xData,p)-yData)*(fmodel(xData,p)-yData)';
errorRel = @(p) (fmodel(xData,p)./yData-1)*(fmodel(xData,p)./yData-1)';
errorLog = @(p) (log(fmodel(xData,p))-log(yData))*(log(fmodel(xData,p))-log(yData))';

% 1
% pfit = fminsearch(errorLog,p0);
% % 2
% p0 = pfit;
% pfit = fminsearch(errorLog,p0);
% 
% p0 = pfit;
% pfit = fminsearch(errorLog,p0);
% 
% p0 = pfit;
% pfit = fminsearch(errorLog,p0);
% 
% p0 = pfit;
% pfit = fminsearch(errorLog,p0);

options = optimset('MaxFunEvals', 1e5);
pfit = fminsearch(errorLog,p0, options)

plot(xData,fmodel(xData,pfit));
% plot(xData,xData.^(-1.5));

G16 = G15;
G16(G15>pfit(7)) = 0;
PlotFieldImage(G16.*grainMaskDil.*mixZone);
