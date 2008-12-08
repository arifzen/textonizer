function [rgbImg, lumImg, chrImg] = loadImage(imageName)

filePath = ['..\in\', imageName];
rgbImg = imread(filePath);

if size(rgbImg,3) == 1
    lumImg = double(rgbImg);
    chrImg = [];
else
    temp = rgb2ntsc(rgbImg);
    lumImg = double(temp(:,:,1));
    chrImg = double(temp(:,:,2:3));
end

