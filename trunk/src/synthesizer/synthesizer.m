function [newImg] = synthesizer(origImg, textons, config, cache)

newSize =config.newSize;
canvas = zeros([newSize 3]);
canvasMask = zeros(newSize);

if false
    tileSize = 80;
    Y = imagequilt(origImg, tileSize, ceil(max(newSize)/(tileSize-round(tileSize / 6))));
    Y = uint8(Y);
    newImg = Y(1:newSize(1),1:newSize(2),1:3);
end

if true
    for textonClass = 1:length(textons.classes)
        for textonIter = 1:length(textons.classes{textonClass})
            drawnow;
            imshow(uint8(canvas));
            texton = textons.classes{textonClass}(textonIter).image;
            mask = textons.classes{textonClass}(textonIter).mask;

            % Find place to place texton
            A = ssd(canvasMask,mask);
            [maxValue,maxInd] = sort(A(:));
            p = maxValue/sum(maxValue);
            p2 = cumsum(p);
            maxInd2 = maxInd(find(p2>rand,1,'first'));
            [point(1),point(2)] = ind2sub(size(A),maxInd2);

            % Draw texton to image
            leftPoint = point-round(size(mask)/2);
            for r =1:size(mask,1)
                for c = 1:size(mask,2)
                    target = leftPoint+[r-1,c-1];
                    if target(1) >= 1 && target(2) >= 1 && target(2) <= newSize(2) && target(1) <= newSize(1)
                        isBit = mask(r,c);

                        if isBit
                            canvasMask(target(1),target(2)) = 1;
                            canvas(target(1),target(2),:) = texton(r,c,:);
                        end
                    end
                end
            end
        end
    end
    textonImg = uint8(canvas);

    % Now perform image completion
    canvas = completePoisson(canvas);
    poissonImg = uint8(canvas);
    
    save TEMP
else
    load TEMP
end

canvas = quilt(canvas,canvasMask,origImg,40);

newImg = uint8(canvas);

clf;
subplot(2,2,1), subimage(origImg);
title('Original image');
subplot(2,2,2), subimage(textonImg);
title('Textonized image');
subplot(2,2,3), subimage(poissonImg);
title('Poissonized image');
subplot(2,2,4), subimage(newImg);
title('Synthesized image');
