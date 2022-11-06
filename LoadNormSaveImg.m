function [normImFilt, normIm, rawIm] = LoadNormSaveImg(n, inPath, imRange, mask, ...
    brightIm, maxImFilt, i, outPath)
%LOAD NORMALIZE SAVE IMAGE Load, normalize and save single images
%   Load an image normalize it according to a reference image

% Load the image (16-bit)
        rawIm = fliplr(double(imread(inPath, n)))./(2^16-1);
        % Limit the range
        rawIm = rawIm(imRange{1}, imRange{2});
        
        % Normalize the image
        [normIm, ~] = NormIntensImg(rawIm, mask, brightIm);
        
        %     Filter the image
        normImFilt = imfilter(normIm, ones(5)./(5^2));
        
        %     Divide by the maximum image
        normImFilt = normImFilt./maxImFilt;
        
        % Remove the grains from the concentration image
        normImFilt(~mask) = 0;
        
        %         Convert back to 16-bit
        normImFilt16 = uint16(normImFilt.*(2^16-1));
        
        fnamesave = fullfile(outPath, sprintf('norm_img_%04d.tiff', i));
        imwrite(normImFilt16, fnamesave)
end

