%% Clean the gradient image

modelFits = [];
meanGrad = [];

for frIdx = [15:25];

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
PlotFieldImage(G12.*grainMaskDil.*mixZone);
title('G(CMaxImDil)=0')
caxis([0 50000])
figure; histogram(nonzeros(G12(grainMaskDil(mixZone))))
set(gca, 'xscale', 'log', 'YScale', "log")
[h, b] = histcounts(nonzeros(G12(grainMaskDil(mixZone))));
% figure; loglog(h, 'o')
[m,i] = min(h)
% b(i)
G13 = G12;
G13(G13>b(i))==0;
% PlotFieldImage(G13.*grainMaskDil, 'G13.*grainMaskDil');
% % caxis([0 b(i)])
% figure; histogram(nonzeros(G13(grainMaskDil)))
% set(gca, 'xscale', 'log', 'YScale', "log")
[h13, b13] = histcounts(nonzeros(G13(grainMaskDil)));
[m13,i13] = min(h13)
% b13(i13)
G14 = G13;
G14(G13>b13(i13))=0;
% PlotFieldImage(G14.*grainMaskDil.*mixZone);
% caxis([0 b13(i13)])
% figure; histogram(nonzeros(G14(grainMaskDil)))
set(gca, 'xscale', 'log', 'YScale', "log")
[h14, b14] = histcounts(nonzeros(G14(grainMaskDil)));
[m14,i14] = min(h14)
b14(i14)
G15 = imfilter(G14, ones(3)./(3^2));
% PlotFieldImage(G15.*grainMaskDil.*mixZone);
% caxis([0 b14(i14)])
% mean(G15(grainMaskDil(mixZone)))
% figure; histogram(nonzeros(G15(grainMaskDil)))

data = nonzeros(G15(grainMaskDil));
edges = logspace(log10(min(data)),log10(max(data)),100);
H = histcounts(data,edges,'normalization','pdf');
xEd = (edges(2:end)+edges(1:end-1))/2;
% figure;
% plot(xEd, H, 'o');
% set(gca, 'xscale', 'log', 'YScale', "log")
% set(gca, 'XLim', [1e3 2e5])
% hold on

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
% title(sprintf('gradient distribution image %d', frIdx))

% plot(xData,fmodel(xData,pfit));
% plot(xData,xData.^(-1.5));

modelFits = [modelFits; pfit];

G16 = G15;
ff = sort(pfit([3 5 7]));
% G16(G15>ff(2)) = 0;
G16(G15>3.5e4) = 0;
PlotFieldImage(G16.*grainMaskDil.*mixZone, sprintf('gradient image %d after treatment', ...
    frIdx));

meanGrad = [meanGrad, mean(G16(grainMaskDil(mixZone)))];

end