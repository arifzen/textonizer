function [textons] = eranMethod(img, textonMap, config)

tClusterAmount = max(textonMap(:));
[rgbImg, lumImg, chrImg] = factorizeImage(img);

textons = [];
textons.classes = cell(tClusterAmount,1);

for iter = 1:tClusterAmount

    fprintf('Working on texton channel %d\n', iter);

    textonChannelMask = (textonMap == iter);
    borderImg = edge(lumImg.*textonChannelMask,'canny',0);
    %tightMap = extractWatertight((~textonChannelMask) | (borderImg));
    tightMap = watertight((~textonChannelMask) | (borderImg));

    areas = unique(tightMap(:));
    nzzs = hist(tightMap(:),areas);

    if numel(areas) == 1
        continue;
    end
    switch config.texton_amount_method
        case 'absolute'
            textonPerClass = config.texton_per_class;
            [values, indices] = sort(nzzs,'descend');
            largeAreas = areas(indices(2:(textonPerClass+1)));

        case 'threshold'
            minTextonArea = config.min_texton_area;
            largeAreas = setdiff(areas(nzzs > minTextonArea),0);
    end
    
    textonClassSize = numel(largeAreas);
    textonClass = struct(...
        'box',cell(textonClassSize,1), ...
        'mask',cell(textonClassSize,1),...
        'image',cell(textonClassSize,1));
        
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
        textonClass(counter).box = bb;
        textonClass(counter).mask = logical(mask(bb(1):bb(3),bb(2):bb(4)));
        textonClass(counter).image = texton;

        %imshow(texton);
        %pause;
    end
    textons.classes{iter} = textonClass;
end
