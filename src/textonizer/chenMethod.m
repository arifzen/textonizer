function [textons] = chenMethod(img, textonMap, config)
    %CHENMETHOD Summary of this function goes here
    %   Detailed explanation goes here

    tClusterAmount = max(textonMap(:));
    [rgbImg, lumImg, chrImg] = factorizeImage(img);

    patchScaleClusterAmount = config.scales_amount;
    windowSizes = config.window_sizes;
    windowOverlap = config.window_overlap;

    scaleAmount = size(windowSizes,1);
    smallestScale = windowSizes(1,:);

    % Extract histograms for each scale
    for iter = 1:scaleAmount
        windowSize = windowSizes(iter,:);

        [H{iter}, coord{iter}] = extractHistograms(textonMap, ...
            tClusterAmount, windowSize, 2./windowSize);
    end

    %minHistAmount = min(cellfun(@(x) size(x,2), H));
    %histAmount = sum(cellfun(@(x) size(x,2), H));
    %avgHistAmount = histAmount/scaleAmount;

    centroids = [];
    % Cluster for each scale
%     for iter = 1:scaleAmount
% 
%         [clusterInd, temp, sumD, D] = kmeans(H{iter}', minHistAmount, ...
%             'replicates', 2,'EmptyAction', 'drop');
% 
%         centroids = [centroids;temp];
% 
%         %showTextonPatches(textonPatches, 10);
%     end
    
    pClusterAmount = config.texton_clusters;
    
    % Cluster over all scales
    [clusterInd, centroids, sumD, D] = kmeans(log(1+H{1}'), ...
        pClusterAmount, 'replicates', 2,'EmptyAction', 'drop');

    %% Preform NN search to obtain patches
    %[clusterInd, clusterDist] = BruteSearchMex(centroids, cell2mat(H)','k',1);

    % Selection - Cluster each texton class to predefined number
    selectInd = NaN(config.texton_per_class, pClusterAmount);
    for pClusterIter = 1:pClusterAmount

        pInd = find(clusterInd == pClusterIter)';    
        curH = H{1}(:,pInd);
        if numel(pInd) > config.texton_per_class    
            [clusterInd2, centroids2, sumD2, D2] = kmeans(curH', ...
                config.texton_per_class, 'replicates', 4,'EmptyAction', 'singleton');
            [J,I] = min(D2);
            selectInd(:, pClusterIter) = pInd(I)';            
        end        
    end
    
    selectInd = selectInd(:);
    selectInd = selectInd(~isnan(selectInd));
    coords = cell2mat(coord');
    
    %selectInd = 1:length(clusterInd);
    
    textonPatches = extractTextonPatches(rgbImg, ...
        coords(selectInd,:), clusterInd(selectInd), D(selectInd,:), pClusterAmount);

    showTextonPatches(textonPatches, 10);
    
    textons = textonPatches;
end