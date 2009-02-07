function [ windows, coord ] = extractWindows(img, width, height, overlapW, overlapH)
%EXTRACTWINDOWS Summary of this function goes here
%   Detailed explanation goes here

% Convert from ratio to abs
overlapW = round(overlapW*width);
overlapH = round(overlapH*height);

imgWidth = size(img, 2);
imgHeight = size(img, 1);

widthInd = 1:overlapW:(imgWidth-width);
heightInd = 1:overlapH:(imgHeight-height);

windowAmount = length(widthInd)*length(heightInd);

windows = zeros(windowAmount,height,width,'uint8');
coord = zeros(windowAmount,4');

counter = 1;
for iterx = widthInd
    for itery = heightInd
        coord(counter, :) = [itery,(itery+height-1), iterx,(iterx+width-1)];
        windows(counter, :, :) = img(coord(counter,1):coord(counter,2), coord(counter,3):coord(counter,4));
        counter = counter + 1;
    end
end

end