function [newImg] = synthesizer(origImg, textons, config, cache)

origSize = size(origImg);
newSize =config.newSize;
scale = prod(newSize)/prod(origSize(1:2));
canvas = zeros([newSize 3]);
canvasMask = logical(zeros(newSize));
isAddingTextons = true;
map = textons.map;

% Transform texton map
%keyboard;

if true
    switch config.map.method;
        case 'tile'
        case 'quilt'
            tileSize = 40;
            Y = imagequilt(map, tileSize, ceil(max(newSize)/(tileSize-round(tileSize / 6))));
            map = Y(1:newSize(1),1:newSize(2),1);
        otherwise
            assert(false,'Bad map method!');
    end
    save TEMP;
else
    load TEMP;
end

figure;
imagesc(map);

if false
    tileSize = 40;
    Y = imagequilt(origImg, tileSize, ceil(max(newSize)/(tileSize-round(tileSize / 6))));
    Y = uint8(Y);
    newImg = Y(1:newSize(1),1:newSize(2),1:3);
    newImg = uint8(newImg);
    imshow(newImg);
    pause;
end

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

textonAmount = counter;
textonPixelAmount = sum(sizes);
desiredPixels = round(scale*textonPixelAmount);
pixelsAdded = 0;
[textonVal,textonInd] = sort(sizes,'descend');

addCounter = zeros(1,textonAmount);
addLimit = ones(1,textonAmount)*1;

isLastEffort = false;

% Add textons to the canvas until decided
while isAddingTextons

    % Select current texton
    weights = (addLimit-addCounter).*(sizes.*(sizes<=(desiredPixels-pixelsAdded)));
    index = weightedSelect(weights);

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

    % Load texton data
    texton = double(textons.classes{textonClass}(textonIter).image);
    mask = textons.classes{textonClass}(textonIter).mask;
    box = textons.classes{textonClass}(textonIter).box;

    % Find place to place texton
    switch(config.method)
        case 'tile'
            leftPoint = box(1:2);
        case 'sparse'

            %A = sad(~canvasMask,mask);
            %A = A.*classMask(1:size(A,1),1:size(A,2));

            %A = sad((classMask{textonClass}.*(~canvasMask)),mask);

            B = (0.1+0.5*exp(-0.1*bwdist(~classMask{textonClass}))).*classMask{textonClass};
            A = sad(B.*(~canvasMask),mask);
            
            if true
                [maxValue,maxInd] = sort(A(:));
                p = maxValue/sum(maxValue);
                p2 = cumsum(p);
                maxInd2 = maxInd(find(p2>rand,1,'first'));
            else
                [maxValue,maxInd2] = max(A(:));
            end
            [point(1),point(2)] = ind2sub(size(A),maxInd2);
            leftPoint = point;
        case 'stich'

            % Get texton frame
            frame = double(origImg(box(1):box(3),box(2):box(4),:));

            % Get texton border
            border = frame.*repmat(~mask,[1,1,3]);

            % Calc maps
            [distances, surveySizes] = ssdMask(canvas,border,canvasMask,~mask);

            collisions = 1-sad((classMask{textonClass}.*(~canvasMask)),mask)/sum(mask(:));
            %collisions = 1-sad(~canvasMask,mask)/sum(mask(:));

            % Combine scores

            A = (exp(-distances)-0.5).*surveySizes - collisions;

            if false
                [maxValue,maxInd] = sort(A(:));
                p = maxValue/sum(maxValue);
                p2 = cumsum(p);
                maxInd2 = maxInd(find(p2>rand,1,'first'));
            else
                [maxValue,maxInd2] = max(A(:));
            end
            [point(1),point(2)] = ind2sub(size(A),maxInd2);
            leftPoint = point;

        otherwise
            assert(false,'Bad method!');
    end

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

    drawnow;
    imshow(uint8(canvas));
    %imshow(canvas);

    if pixelsAdded >= desiredPixels
        isAddingTextons = false;
    end
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

function Z = sad(X, Y)

for k=1:size(X,3),
    A = X(:,:,k);
    B = Y(:,:,k);

    ab = filter2(B, A, 'valid');

    if( k == 1 )
        Z = ab;
    else
        Z = Z + ab;
    end;
end;

function [Z,surveySizes] = ssdMask(X, Y, Am, Bm)
% Perform SSD with respect to alpha values

K = ones(size(Y,1), size(Y,2));

for k=1:size(X,3),
    A = X(:,:,k);
    B = Y(:,:,k);

    a2 = filter2(K, A.^2, 'valid');
    b2 = sum(sum(B.^2));
    ab = filter2(B, A, 'valid').*2;

    b2am = filter2(B.^2, ~Am, 'valid');
    a2bm = filter2(~Bm, A.^2, 'valid');

    if( k == 1 )
        Z = (a2 - ab + b2 -b2am -a2bm);
    else
        Z = Z + (a2 - ab + b2 -b2am -a2bm);
    end;
end;

surveySizes = filter2(Bm, Am, 'valid')./sum(Bm(:));
