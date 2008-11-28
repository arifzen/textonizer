function [textons] = extractTextons(img)
%EXTRACTTEXTONS Summary of this function goes here
%   Detailed explanation goes here

width = 64;
height = 64;

% Extract windows
windows = extractWindows(img, width, height);

windowAmount = size(windows, 1);

% Build kernel matrix
K = calcKernel(windows);

% Feature extraction
featuresAmount = 5;
selectedFeatures = NaN(5,1);
W = ones(windowAmount, 1);
for iter = 1:featuresAmount
    A = K*W;
    [maxValue, maxFeature] = max(A);
    selectedFeatures(iter) = maxFeature;    
end

textons = windows(selectedFeatures);

end