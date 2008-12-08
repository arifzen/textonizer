function [textonMap, textonPatches] = textonizer(filename)
%TEXTONIZER Summary of this function goes here
%   Detailed explanation goes here

% Set variables
tClusterAmount = 3;
pClusterAmount = 6;
windowSize = [20 20];

% Create filter bank
para = design_filter_bank(pi/8,3);
filterBank = create_gabor_filter_bank(para);

% Load image
[rgbImg, lumImg, chrImg] = loadImage(filename);

% Extract features
X = extractFeatures(lumImg, chrImg, filterBank);

% Calc textons
textonMap = calcTextons(X, tClusterAmount, size(lumImg));
%showTextons(filterBank, centroids);
showTextonMap(textonMap);
showTextonChannels(rgbImg, textonMap);

% Extract Histograms
[H, coord] = extractHistograms(textonMap, tClusterAmount, windowSize);

% Calc texton patches
textonPatches = calcTextonPatches(rgbImg, coord, H, pClusterAmount);
showTextonPatches(textonPatches, 10);

