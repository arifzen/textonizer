function [ windows ] = extractWindows(img, width, height)
%EXTRACTWINDOWS Summary of this function goes here
%   Detailed explanation goes here

imgWidth = size(img, 2);
imgHeight = size(img, 1);

widthInd = 1:width:(imgWidth-width);
heightInd = 1:height:(imgHeight-height);
windowAmount = length(widthInd)*length(heightInd);

windows = zeros(windowAmount,width,height,'uint8');

counter = 1;
for iterx = widthInd
    for itery = heightInd
        windows(counter, :, :) = img(itery:(itery+height-1), iterx:(iterx+width-1));
        counter = counter + 1;
    end
end

end