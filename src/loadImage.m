function [ img ] = loadImage(imageName)

filePath = ['..\in\', imageName];
img = imread(filePath);


