function [outImgName, outImgPath, outImg] = LoadCropImgSer(imgFolderIn, ...
    imgNameIn, imgDir, outType, varargin)
%LOADCROPIMGSER Load imageS from a series and crop to size
%   Load an image from a file and crop it according to size.
%   INPUT:
%   imgFolderIn: The image folder
%   imgNameIn: The images name
%   imgDir: the direction of the image; if -1 reverse from left to right,
%   if 1 keep the original direction.
%   outType: output image type, 0 for logical and 1 for double.
%   varargin: Set of optional input paramteres; 1- image type, 2- bit
%   depth, 3- show a text message while loading the image, 4- the range of
%   pixels to include.



if length(varargin)==4
    imgType = varargin{1};
    bitDepth = varargin{2};
    dispTxt = varargin{3};
    imgRng = varargin{4};
elseif length(varargin)==3
    imgType = varargin{1};
    bitDepth = varargin{2};
    dispTxt = varargin{3};
    imgRng = {':' ':'};
elseif length(varargin)==2
    imgType = varargin{1};
    bitDepth = varargin{2};
    dispTxt = '';
    imgRng = {':' ':'};
elseif length(varargin)==1
    imgType = varargin{1};
    bitDepth = 16;
    dispTxt = '';
    imgRng = {':' ':'};
elseif length(varargin)==0
    imgType = 'png';
    bitDepth = 16;
    dispTxt = '';
    imgRng = {':' ':'};
end

outImgName = imgNameIn;
outImgPath = imgFolderIn;

if imgDir==(-1)
    outImg0 = double(fliplr(imread(fullfile(outImgPath, outImgName), ...
        imgType)))./(2^bitDepth-1);
elseif imgDir==1
    outImg0 = double(imread(fullfile(outImgPath, outImgName), ...
        imgType))./(2^bitDepth-1);
end

if outType==0
    outImg = logical(outImg0(imgRng{1}, imgRng{2}));
elseif outType==1
    outImg = outImg0(imgRng{1}, imgRng{2});
end

end