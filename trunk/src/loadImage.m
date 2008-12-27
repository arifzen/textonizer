function [rgbImg] = loadImage(imageName)

filePath = ['..\in\', imageName];
rgbImg = imread(filePath);
