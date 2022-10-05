function [outImage] = img_register(inImg, xShift, yShift)
% A simple, manual registration procedure

% Shift horizontally, padd with zeros
if xShift>0
    interImg = [zeros(size(inImg,1), xShift) inImg(:,1:end-xShift)];
elseif xShift<0
    interImg = [inImg(:,abs(xShift):end) zeros(size(inImg,1), abs(xShift))];
elseif xShift==0
    interImg = inImg;
end

% Shift vertically, padd with zeros
if yShift>0
    outImage = [zeros(yShift, size(interImg,2)); interImg(1:end-yShift, :)];
elseif yShift<0
    outImage = [interImg(abs(yShift)+1:end, :); zeros(abs(yShift), size(interImg,2))];
elseif yShift<0
    outImage = interImg;
end

end