function [textons] = extractSemanticTextons(img, textonMap, config)
%EXTRACTSEMANTICTEXTONS Summary of this function goes here
%   Detailed explanation goes here

tClusterAmount = max(textonMap(:));
[rgbImg, lumImg, chrImg] = factorizeImage(img);

switch(config.method)
    case 'eran'
        textons = cell(tClusterAmount,1);
        for iter = 1:tClusterAmount
            
            fprintf('Working on texton channel %d\n', iter);
            
            textonChannelMask = (textonMap == iter);
            borderImg = edge(lumImg.*textonChannelMask,'canny',0);
            tightMap = extractWatertight((~textonChannelMask) | (borderImg));
            
            areas = unique(tightMap(:));
            nzzs = hist(tightMap(:),areas);
            
            switch config.texton_amount_method
                case 'absolute'                
                    textonPerClass = config.texton_per_class;
                    [values, indices] = sort(nzzs,'descend');
                    largeAreas = areas(indices(2:(textonPerClass+1)));

                case 'threshold'
                    minTextonArea = config.min_texton_area;
                    largeAreas = setdiff(areas(nzzs > minTextonArea),0);
            end
            
            textonClass = cell(numel(largeAreas),1);
            counter = 0;
            
            fprintf('Found %d closed regions - selecting %d largest\n', ...
                numel(areas), numel(largeAreas));
            
            for curArea = largeAreas'                
                
                % Create mask
                mask = uint8(tightMap==curArea);
                
                if config.fill_holes
                    mask = imfill(mask,'holes');
                end

                % Find bounding-box
                [r,c] = ind2sub(size(lumImg),find(mask));
                bb = [min(r),min(c),max(r),max(c)];
                
                % Extract texton
                temp = repmat(mask,[1,1,size(img,3)]);
                texton = img.*temp;
                texton = imcrop(texton, [bb(2),bb(1),bb(4)-bb(2),bb(3)-bb(1)]);

                counter = counter + 1;                
                textonClass{counter} = texton;

                %imshow(texton);
                %pause;                
            end
            textons{iter} = textonClass;
        end
        
    case 'chen'
        
        patchScaleClusterAmount = 10;
        windowSizes = [40 40];
        windowOverlap = [0.5 0.5];
        
        scaleAmount = size(windowSizes,1);
        smallestScale = windowSizes(1,:);

        % Extract histograms for each scale
        for iter = 1:scaleAmount
            windowSize = windowSizes(iter,:);

            % Extract Histograms
            [H{iter}, coord{iter}] = extractHistograms(textonMap, ...
                tClusterAmount, windowSize, smallestScale./windowSize);
        end

        minHistAmount = min(cellfun(@(x) size(x,2), H));
        histAmount = sum(cellfun(@(x) size(x,2), H));
        avgHistAmount = histAmount/scaleAmount;

        centroids = [];
        % Cluster for each scale
        for iter = 1:scaleAmount

            [clusterInd, temp, sumD, D] = kmeans(H{iter}', minHistAmount, ...
                'replicates', 2,'EmptyAction', 'drop');

            centroids = [centroids;temp];

            %showTextonPatches(textonPatches, 10);
        end

        % Cluster over all scales
        [clusterInd, centroids, sumD, D] = kmeans(centroids, pClusterAmount, ...
            'replicates', 2,'EmptyAction', 'drop');

        % Preform NN search to obtain patches
        [clusterInd, clusterDist] = BruteSearchMex(centroids, cell2mat(H)','k',1);

        textonPatches = extractTextonPatches(rgbImg, cell2mat(coord'), clusterInd, clusterDist, pClusterAmount);

        showTextonPatches(textonPatches, 10);
    otherwise
        assert(false);
end
