function [outImg] = Save16BitImage(inImg, normFact, outImgFold, i, dirStr, imgNamePre)
% SAVE 16 BIT IMAGES Save double arrays as 16 bit images

outImg = uint16(inImg./normFact*(2^16-1));
if ~exist(fullfile(outImgFold, dirStr), "dir")
    mkdir(fullfile(outImgFold, dirStr))
end
imwrite(outImg, fullfile(outImgFold, dirStr, sprintf('%s_16_%03d.png', imgNamePre, i)))

end

