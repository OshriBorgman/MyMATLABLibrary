function bd_mask2=compute_interface_2(im, grain_im, maxval, w_smooth, side_l, visu)

% % COMPUTE INTERFACE 2 Compute the mixing interface from a concentration
% image

%%% Typical values for the parameters:
%%%
%%%   w_smooth = 3
%%%   

% % UPDATES
% 05/08/2020 - I increased the threshold for creating im5, from 0.5 to 0.8.
% This way I can considerably smooth the interface, which should help with
% analyzing the folding points. I also added a morphological function to
% remove spurs in the final interface, after skeletonization.
% 14/01/2021 - I added the grain images as a reference to the maximum
% concentration, to calculate the C/C0=0.5 point.
% In addition, I enforce a value of C/C0=0.5 + 1 for the first 5 rows of
% the image, to create a connected cluster earlier and enable the
% calculation of the interface for the mixing time.


% %%% First computing a mask that corresponds to values > maxval/2, and
% %%% in that mask, putting pixels corresponding to reflections to 0
% maxval=max(im(grain_im))/2;

% Fill the first few rows of the image, to create a connected cluster
im(:,1:5) = maxval+0.01;

suphalf_im=zeros(size(im));
suphalf_im(im>maxval)=1;

im2=suphalf_im;

if visu > 1
    figure(20)
    subplot(3,1,1)
    imagesc(im), axis equal tight, colorbar();
    title('original concentrations image')
    subplot(3,1,2)
    imagesc(suphalf_im), axis equal tight, colorbar();
    title('Concentration larger than 0.5')
    subplot(3,1,3)
    imagesc(im2), axis equal tight, colorbar();
    title('after removing the reflections')
end

%%% Defining a new mask from the largest connected white cluster in the
%%% previous mask
CC=bwconncomp(im2);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
im3=zeros(size(im2));
im3(CC.PixelIdxList{idx})=1;

if visu > 1
    figure(21)
    imagesc(im2+2*im3), axis equal tight, colorbar();
    title('highlighting the largest cluster')
end

%%% Smoothing the previous mask with a Gaussian filter of width w_smooth, and  removing the 
%%% resulting values that are smaller than 0.5. This removes finger that are of width ~ w_smooth
% im3 = im2;

im4= imgaussfilt(im3,w_smooth);

if visu > 1
    figure(21)
    subplot(2,1,1)
    imagesc(im3), axis equal tight, colorbar();
    title('largest cluster only')
    subplot(2,1,2)
    imagesc(im4), axis equal tight, colorbar();
    title('after applying gaussian filter')
end
    
im5=im3;
% % Original condition
% im5(im4<=0.5)=0;
% % Original
% OB 05/08/2020
im5(im4<=0.8)=0;
% OB 05/08/2020

%%% Keeping just the largest connected white cluster from the latter mask

CC2=bwconncomp(im5);
numPixels = cellfun(@numel,CC2.PixelIdxList);
[biggest,idx] = max(numPixels);
im6=zeros(size(im));
im6(CC2.PixelIdxList{idx})=1;

if visu > 1
    figure(22)
    clf
    subplot(3,1,1)
    imagesc(im5), axis equal tight, colorbar();
    title('filtered image thresholded')
    subplot(3,1,2)
    imagesc(im3+2*im5), axis equal tight, colorbar();
    title('previous and thresholded image')
    subplot(3,1,3)
    imagesc(im3+2*im6), axis equal tight, colorbar();
    title('highlighting the main cluster')
end

%%% Chopping off two lateral strips and removing the grains behind the
%%% interface from the mask
im6=im6(side_l:end+1-side_l,:);
CC3=bwconncomp(1-im6);
numPixels = cellfun(@numel,CC3.PixelIdxList);
[biggest,idx] = max(numPixels);
im7=zeros(size(im6));
im7(CC3.PixelIdxList{idx})=1;

if visu > 1
    figure(23)
    clf
    subplot(3,1,1)
    imagesc(im6+2*im7), axis equal tight, colorbar();
    title('final treated image')
%subplot(3,1,2)
end

%%%% Computing the interface line from the last mask
[gradx,grady]=gradient(im7);
grad=sqrt(gradx.^2+grady.^2);
bd_mask=zeros(size(im6));
bd_mask(grad>0)=1;
bd_mask2=bwskel(logical(bd_mask));

% OB 05/08/2020
bd_mask2=bwmorph(bd_mask2, 'spur', 5);
% OB 05/08/2020

if visu > 0
    figure(24)
    subplot(2,1,1)
    imagesc(im7+2*bd_mask), axis equal tight, colorbar();
    title('interface before morphological functions')
    subplot(2,1,2)
    imagesc(im7+2*bd_mask2), axis equal tight, colorbar();
    title('and after')
end

% figure(25)
% imagesc(bd_mask2), axis equal tight
% title('Final interface')

return

