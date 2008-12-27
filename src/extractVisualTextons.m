function [textonMap] = extractVisualTextons(img, config)
%EXTRACTVISUALTEXTONS Summary of this function goes here
%   Detailed explanation goes here

[rgbImg, lumImg, chrImg] = factorizeImage(img);

% Set variables
tClusterAmount = config.texton_clusters;

% Create filter bank
para = design_filter_bank(config.fb.orientations, config.fb.scales);
filterBank = create_gabor_filter_bank(para);

% Extract features
X = extractFeatures(lumImg, chrImg, filterBank);

% Calc textons
textonMap = calcTextons(X, tClusterAmount, size(lumImg));
%showTextons(filterBank, centroids);

%showTextonMap(textonMap);
%pause;
%showTextonChannels(rgbImg, textonMap);
%pause;
