function [rgbImg] = loadImage(imageName)

filePath = fullfile(getConst('INPUT_PATH'),imageName);
rgbImg = imread(filePath);
