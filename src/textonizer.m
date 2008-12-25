function [textonMap, textonPatches] = textonizer(filename)
%TEXTONIZER Summary of this function goes here
%   Detailed explanation goes here

clf;

if exist('CACHE','file')
    load CACHE;
else

    % Set variables
    isEran = false;
    tClusterAmount = 3;
    pClusterAmount = 3;
    patchScaleClusterAmount = 10;
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

    save CACHE;
end

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
    scaleAmount = size(windowSizes,1);
    smallestScale = windowSizes(1,:);
    
    % Extract histograms for each scale
    for iter = 1:scaleAmount
        windowSize = windowSizes(iter,:);
        
        % Extract Histograms
        [H{iter}, coord{iter}] = extractHistograms(textonMap, ...
            tClusterAmount, windowSize, smallestScale./windowSize);
    end
    
    histAmount = sum(cellfun(@(x) size(x,2), H));    
    avgHistAmount = histAmount/scaleAmount;
    
    centroids = [];
    % Cluster for each scale
    for iter = 1:scaleAmount
        
        [clusterInd, centroids, sumD, D] = kmeans(H', pClusterAmount, ...
            'replicates', 2,'EmptyAction', 'drop');

        centroids = [centroids;temp];
        
        showTextonPatches(textonPatches, 10);
    end

    % Cluster over all scales
    [textonPatches, centroids{iter}] = calcTextonPatches(rgbImg, coord{iter}, centroids, pClusterAmount);
    showTextonPatches(textonPatches, 10);            
    
end
