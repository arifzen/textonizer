function [canvas, canvasMask] = drawTexton(canvas, canvasMask, point, textonImage, textonMask)

newSize = size(canvas);

for r =1:size(textonMask,1)
    for c = 1:size(textonMask,2)
        target = point+[r-1,c-1];
        if target(1) >= 1 && target(2) >= 1 && target(2) <= newSize(2) && target(1) <= newSize(1)
            isBit = textonMask(r,c);
            if isBit
                if canvasMask(target(1),target(2))
                    %canvas(target(1),target(2),:) = (canvas(target(1),target(2),:)+textonImage(r,c,:))/2;
                    canvas(target(1),target(2),:) = canvas(target(1),target(2),:);
                else
                    canvasMask(target(1),target(2)) = 1;
                    canvas(target(1),target(2),:) = textonImage(r,c,:);
                end
            end
        end
    end
end
