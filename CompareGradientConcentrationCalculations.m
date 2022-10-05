%%
PlotFieldImage(GImage, 'G')
caxis([0 5e4])
mean(nonzeros(GImage))
colormap(GreenFireBlue)

%%
GImageFilt = GImage;
GImageFilt(CImageFilt>(0.95*CMax)) = 0;
PlotFieldImage(GImageFilt, 'G filtered');
mean(nonzeros(GImageFilt))
caxis([0 5e4])
colormap(GreenFireBlue)

%%
PlotFieldImage(CImage.*grainMaskTrim, 'c');
colormap(bl_to_rd_diver_cmap)
caxis([0 CMax])

%% Filter image by 3 point matrix and calculate gradient
CImageFilt3 = imfilter(CImage, ones(3)./(3^2));
PlotFieldImage(CImageFilt3.*grainMaskTrim, 'c filtered 3 points');
colormap(bl_to_rd_diver_cmap)
caxis([0 CMax])

[Gx, Gy] = gradient(CImageFilt3.*grainMaskTrim, 1);
GImage = sqrt(Gx.^2 + Gy.^2);
GImage(~grainMaskDil) = 0;
GImage(:,1:3) = 0;
GImage3 = real(GImage)./(pixLen*1e-3);

PlotFieldImage(GImage3, 'G for c filtered 3 points');
caxis([0 2e5])
mean(nonzeros(GImage3))
colormap(GreenFireBlue)

%% Filter image by 5 point matrix and calculate gradient
CImageFilt5 = imfilter(CImage, ones(5)./(5^2));
PlotFieldImage(CImageFilt5.*grainMaskTrim, 'c filtered 3 points');
colormap(bl_to_rd_diver_cmap)
caxis([0 CMax])

[Gx, Gy] = gradient(CImageFilt5, 1);
GImage = sqrt(Gx.^2 + Gy.^2);
GImage(~grainMaskDil) = 0;
GImage(:,1:3) = 0;
GImage5 = real(GImage)./(pixLen*1e-3);

PlotFieldImage(GImage5, 'G for c filtered 5 points');
caxis([0 2e5])
mean(nonzeros(GImage5))
colormap(GreenFireBlue)

%% Filter image by 7 point matrix and calculate gradient
CImageFilt7 = imfilter(CImage, ones(7)./(7^2));
PlotFieldImage(CImageFilt7.*grainMaskTrim, 'c filtered 7 points');
colormap(bl_to_rd_diver_cmap)
caxis([0 CMax])

[Gx, Gy] = gradient(CImageFilt7.*grainMaskTrim, 1);
GImage = sqrt(Gx.^2 + Gy.^2);
GImage(~grainMaskDil) = 0;
GImage(:,1:3) = 0;
GImage7 = real(GImage)./(pixLen*1e-3);

PlotFieldImage(GImage7, 'G for c filtered 7 points');
caxis([0 2e5])
mean(nonzeros(GImage7))
colormap(GreenFireBlue)

%% Calculate the gradients with 1 pixels length
[Gx, Gy] = gradient(CImageFilt, 1);
GImage = sqrt(Gx.^2 + Gy.^2);
GImage(~grainMaskDil) = 0;
GImage(:,1:3) = 0;
GImage = real(GImage)./(pixLen*1e-3);

PlotFieldImage(GImage, 'G1');
caxis([0 2e5])
mean(nonzeros(GImage))
colormap(GreenFireBlue)

%% Calculate the gradients with 3 pixels length
[Gx, Gy] = gradient(CImageFilt, 3);
GImage3 = sqrt(Gx.^2 + Gy.^2);
GImage3(~grainMaskDil) = 0;
GImage3(:,1:3) = 0;
GImage3 = real(GImage3)./(pixLen*1e-3).*3;

PlotFieldImage(GImage3, 'G3');
caxis([0 2e5])
mean(nonzeros(GImage3))
colormap(GreenFireBlue)
%% Calculate the gradients with 5 pixels length
[Gx, Gy] = gradient(CImageFilt, 5);
GImage5 = sqrt(Gx.^2 + Gy.^2);
GImage5(~grainMaskDil) = 0;
GImage5(:,1:3) = 0;
GImage5 = real(GImage5)./(pixLen*1e-3).*5;

PlotFieldImage(GImage5, 'G5');
caxis([0 2e5])
mean(nonzeros(GImage5))
colormap(GreenFireBlue)