function [textons] = extractTextons(img)
%EXTRACTTEXTONS Summary of this function goes here
%   Detailed explanation goes here

width = 32;
height = 32;

% Extract windows
windows = extractWindows(img, width, height);

windowAmount = size(windows, 1);

% Build kernel matrix
K = calcKernel(windows);

% Feature extraction
featuresAmount = 5;
selectedFeatures = NaN(5,1);
W = ones(windowAmount, 1);
W = W./sum(W);
for iter = 1:featuresAmount
    A = K*W;
    %plot(A);
    %pause;
    [maxValue, maxFeature] = max(A);
    selectedFeatures(iter) = maxFeature;    
    disp(maxFeature);
    
    P = 1-K(maxFeature,:);
    %P = P./sum(P);
    
    %P = P-min(P);
    %P = P./max(P);
    
    W = (P.*W')';
    %plot(W);
    %pause;
    W = W./sum(W);
%    plot(W);
%    pause;
end

textons = windows(selectedFeatures,:,:);

end