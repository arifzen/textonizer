function [newImg] = synthesizer(origImg, textons, config, cache)

newSize =config.newSize;
canvas = zeros([newSize 3]);
canvasMask = zeros(newSize);

if true
    tileSize = 80;
    Y = imagequilt(origImg, tileSize, ceil(max(newSize)/(tileSize-round(tileSize / 6))));
    Y = uint8(Y);
    newImg = Y(1:newSize(1),1:newSize(2),1:3);
end


for textonClass = 1:length(textons)
    for textonIter = 1:length(textons{textonClass})
        texton = textons{textonClass}{textonIter};
        textonMask = (max(texton,[],3)>0);
        
        
    end
end

newImg = canvas;