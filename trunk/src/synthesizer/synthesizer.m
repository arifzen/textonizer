function [newImg] = synthesizer(origImg, textons, config, cache)

% Init
verbose = 1;
origSize = size(origImg);
newSize =config.newSize;
scale = prod(newSize)/prod(origSize(1:2));
canvas = zeros([newSize 3]);
canvasMask = logical(zeros(newSize));
isAddingTextons = true;
map = textons.map;
textonClassAmount = length(textons.classes);

% Transform texton map

switch config.map.method;
    case 'tile'
    case 'quilt'
        tileSize = 40;
        Y = imagequilt(map, tileSize, ceil(max(newSize)/(tileSize-round(tileSize / 6))));
        map = Y(1:newSize(1),1:newSize(2),1);
    otherwise
        assert(false,'Bad map method!');
end

% Grade new map

figure;
imagesc(map);
origHist = hist(textons.map(:),1:textonClassAmount)
newHist = hist(map(:),1:textonClassAmount)
pause(1);

clf;
subplot(2,4,6), imagesc(map);
title('Synthesized texton map');
axis image

% Preprocessing

counter = 0;
sizes = [];
classIndices = [];
for textonClass = 1:length(textons.classes)
    for textonIter = 1:length(textons.classes{textonClass})
        counter = counter + 1;
        sizes(counter) = sum(textons.classes{textonClass}(textonIter).mask(:));
        classIndices(counter) = textonClass;
        textonIndices(counter) = textonIter;
    end
    classMask{textonClass} = logical(map == textonClass);
end

% Add textons to the canvas until decided

textonAmount = counter;
textonPixelAmount = sum(sizes);
desiredPixels = round(scale*textonPixelAmount);
pixelsAdded = 0;
[textonVal,textonInd] = sort(sizes,'descend');

addCounter = zeros(1,textonAmount);
addLimit = ones(1,textonAmount)*1;

isLastEffort = false;

while isAddingTextons

    % Select current texton    
    weights = (addLimit-addCounter).*(sizes.*(sizes<=(desiredPixels-pixelsAdded)));
    index = weightedSelect((weights./sum(weights)).^0.5,true);
    
    if isempty(index)
        if isLastEffort
            disp('Trying last effort!');
            for classIter = 1:length(textons.classes);
                A = classMask{classIter}.*(~canvasMask);
                classPixelsLeft = sum(A(:));
                ind = find(classIndices == classIter);
                classSizes = sizes(ind);
                [vals,inds] = sort(classSizes);

                pixelsCounter = 0;
                iter = 0;
                while pixelsCounter<(classPixelsLeft-100) && iter < length(vals)
                    iter = iter + 1;
                    pixelsCounter = pixelsCounter+vals(iter);
                end
                inds3 = ind(inds(1:iter));
                addLimit(inds3) = addLimit(inds3)+1;
            end
            isLastEffort = false;
        else
            isAddingTextons = false;
        end
        continue;
    end

    textonClass = classIndices(index);
    textonIter = textonIndices(index);

    % Add selected texton
    addCounter(index) = addCounter(index)+1;
    assert(addCounter(index)<=addLimit(index),'Added more textons than allowed!');
    
    % Load texton data
    texton = double(textons.classes{textonClass}(textonIter).image);
    mask = textons.classes{textonClass}(textonIter).mask;
    box = textons.classes{textonClass}(textonIter).box;
    textonArea = textons.map(box(1):box(3),box(2):box(4));
        
    % Get texton frame
    frame = double(origImg(box(1):box(3),box(2):box(4),:));

    % Get texton border
    border = frame.*repmat(~mask,[1,1,3]);
                   
    % Find place to place texton
    switch(config.method)
        case 'default'          
            
            % Calculate energies            
            Etexton = textonMapEnergy(map, textonArea, textonClassAmount);
            Edistance = distanceEnergy(canvasMask, templateMask, textonChannel);
            Earea = areaEnergy(canvas, area, ~mask);
            
        case 'tile'
            leftPoint = box(1:2);
        case 'map'
            
            [maxValue,maxInd2] = max(A(:));
            
            subplot(2,4,3), imagesc(A);
            axis image
            title('Score: Map Match');
            
            [point(1),point(2)] = ind2sub(size(A),maxInd2);
            leftPoint = point;            
            
            
        case 'stich'            

        otherwise
            assert(false,'Bad method!');
    end
    
    % Select candidate
    if false
        [maxValue,maxInd] = sort(E(:));
        p = maxValue/sum(maxValue);
        p2 = cumsum(p);
        maxInd2 = maxInd(find(p2>rand,1,'first'));
    else
        [maxValue,maxInd2] = max(E(:));
    end
    
    [point(1),point(2)] = ind2sub(size(A),maxInd2);
    leftPoint = point;    
    
    % Draw texton to image
    
    for r =1:size(mask,1)
        for c = 1:size(mask,2)
            target = leftPoint+[r-1,c-1];
            if target(1) >= 1 && target(2) >= 1 && target(2) <= newSize(2) && target(1) <= newSize(1)
                isBit = mask(r,c);

                if isBit
                    if canvasMask(target(1),target(2))
                        canvas(target(1),target(2),:) = (canvas(target(1),target(2),:)+texton(r,c,:))/2;
                    else
                        canvasMask(target(1),target(2)) = 1;
                        canvas(target(1),target(2),:) = texton(r,c,:);
                        pixelsAdded = pixelsAdded+1;
                    end
                end
            end
        end
    end
    
    if pixelsAdded >= desiredPixels
        isAddingTextons = false;
    end
    
    subplot(2,4,2), subimage(uint8(canvas));
    title('Synthesized image');    
    
    subplot(2,4,1), subimage(uint8(texton));
    title('Current Texton');    
    axis image;

    subplot(2,4,5), imagesc(textonArea);
    title('Current Texton area');    
    axis image;    
    
            subplot(2,4,3), imagesc(distances);
            axis image
            title('Score: Distance');

            subplot(2,4,7), imagesc(collisions);
            axis image
            title('Score: Collisions');
                        
            subplot(2,4,8), imagesc(A);
            axis image
            title('Score: Final');
    
    drawnow;
    pause;
end

textonImg = uint8(canvas);

% Now perform image completion
canvas = completePoisson(canvas);
poissonImg = uint8(canvas);


canvas = quilt(canvas,canvasMask,origImg,40);

newImg = uint8(canvas);

clf;

subplot(2,3,1), subimage(origImg);
title('Original image');
subplot(2,3,4), subimage(newImg);
title('Synthesized image');

subplot(2,3,2), subimage(textonImg);
title('Textonized image');
subplot(2,3,5), subimage(poissonImg);
title('Poissonized image');

subplot(2,3,3), imagesc(textons.map);
title('Texton map');
axis image
subplot(2,3,6), imagesc(map);
title('Synthesized texton map');
axis image




