function showTextonChannels(rgbImg, textonMap)
%SHOWTEXTONCHANNELS Summary of this function goes here
%   Detailed explanation goes here

textonInd = unique(textonMap(:));
textonAmount = length(textonInd);

subplot(1, textonAmount+1, 1);
axis image;
subimage(rgbImg);

for iter = 1:textonAmount
    subplot(1, textonAmount+1, iter+1);
    axis image;
    subimage(rgbImg.*repmat(uint8(textonMap == iter),[1 1 3]));
end
drawnow;