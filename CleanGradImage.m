function [gradMask] = CleanGradImage(G)

%CLEAN GRADIENT IMAGE Clean gradient images from background noises and keep
%the important features

% % INPUT
% G: The original gradient image.

% Threshold the gradient image to remove high intensity noise
GThresh = G;
X = nonzeros(G);
[N,edges] = histcounts(X);
idx = find(N<1e2, 1, 'first');
GThresh(G>edges(idx)) = 0;

% Threshold to remove some small values
GThresh2 = GThresh>(1*mean(nonzeros(GThresh)));

% Set the parameters for the morphological functions
rEr = 4;
nEr = 4;
nHood = 4;

% % Erode and dilate the gradient structures to remove small elements and
% % enhance the actual gradient bands
% Use a disk element
% GOpen = imopen(GThresh2, strel('disk',nHood,nEr));
% Use a square element
% GOpen = imopen(GThresh2, strel('square',rEr));
% Use line elements at different orientations
GOpen = imopen(GThresh2, strel('line',rEr,90));
GOpen = imopen(GOpen, strel('line',rEr,0));
GOpen = imopen(GOpen, strel('line',rEr,45));

% Obtain the properties of the non-aqueous phase
gradImgBWLabel = bwlabel(GOpen);
gradImgBWProps = regionprops(gradImgBWLabel, "Orientation", "Area", "Circularity");
% Remove small clusters
excludeClusters = find(abs([gradImgBWProps.Area])<30);
gradImgBWLabel2 = gradImgBWLabel;
gradImgBWLabel2(ismember(gradImgBWLabel,excludeClusters)) = 0;
% Remove clusters not oriented perpendicular to the flow direction
excludeClusters = find(abs([gradImgBWProps.Orientation])>45) ;
gradImgBWLabel3 = gradImgBWLabel2;
gradImgBWLabel3(ismember(gradImgBWLabel2,excludeClusters)) = 0;
% The final gradient mask
gradMask = logical(gradImgBWLabel3);

end

