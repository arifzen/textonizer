function [textonMap, textonPatches] = textonizer(filename)
%TEXTONIZER Summary of this function goes here
%   Detailed explanation goes here

% Set variables
isEran = true;
tClusterAmount = 3;
pClusterAmount = 3;
windowSizes = [10 10;20 20; 40 40];
windowOverlap = [0.5 0.5];

% Create filter bank
para = design_filter_bank(pi/6,4);
filterBank = create_gabor_filter_bank(para);

% Load image
[rgbImg, lumImg, chrImg] = loadImage(filename);

% Extract features
X = extractFeatures(lumImg, chrImg, filterBank);

% Calc textons
textonMap = calcTextons(X, tClusterAmount, size(lumImg));
%showTextons(filterBank, centroids);
showTextonMap(textonMap);

pause;
showTextonChannels(rgbImg, textonMap);
pause;

if isEran
	for iter = 1:tClusterAmount

        %segMap = segment(textonChannel);
        
        textonChannel = lumImg.*(textonMap == iter);
        textonChannelB = (textonMap == iter);
        
        A = double(~edge(textonChannel, 'canny') & textonChannelB);
        B = imfill(A,'holes');
        imshow(B);
	end
else
    % Extract Histograms
    [H, coord] = extractHistograms(textonMap, tClusterAmount, windowSizes, windowOverlap);

    % Calc texton patches
    textonPatches = calcTextonPatches(rgbImg, coord, H, pClusterAmount);
    showTextonPatches(textonPatches, 10);
end
