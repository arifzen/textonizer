function newImg = synthesizer(origImg, textons, config)

%
% Init
%
verbose = 1;
origSize = size(origImg);
newSize = config.newSize;
scale = prod(newSize)/prod(origSize(1:2));
canvas = zeros([newSize 3]);
canvasMask = logical(false(newSize));
isAddingTextons = true;
textonMap = textons.map;
textonClassAmount = length(textons.classes);

%
% New Texton Map
%
newTextonMap = synthTextonMap(textonMap, newSize, config.map);

%
% Preprocessing
%
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
    classMask{textonClass} = logical(newTextonMap == textonClass);
end
textonAmount = counter;
textonPixelAmount = sum(sizes);
desiredPixels = round(scale*textonPixelAmount);

if verbose
    clf;
    subplot(2,4,6), imagesc(newTextonMap);
    title('Synthesized texton map');
    axis image
end

%
% Texton adding
%
pixelsAdded = 0;
addCounter = zeros(1,textonAmount);
addLimit = ones(1,textonAmount)*1;

while isAddingTextons

    % Select candidate texton
    weights = (addLimit-addCounter).*(sizes.*(sizes<=(desiredPixels-pixelsAdded)));
    index = weightedSelect((weights./sum(weights)).^0.5,true);

    % Halt if no candidate left
    if isempty(index)
        isAddingTextons = false;
        continue;
    end

    %
    % Register candidate
    %
    textonClass = classIndices(index);
    textonIter = textonIndices(index);   
    addCounter(index) = addCounter(index)+1;
    assert(addCounter(index)<=addLimit(index),'Added more textons than allowed!');

    %
    % Load candidate data
    %
    textonImage = double(textons.classes{textonClass}(textonIter).image);
    textonMask = textons.classes{textonClass}(textonIter).mask;
    textonBox = textons.classes{textonClass}(textonIter).box;
    textonMapArea = textonMap(...
        textonBox(1):textonBox(3),...
        textonBox(2):textonBox(4));

    % Get texton frame
    textonFrame = double(origImg(...
        textonBox(1):textonBox(3),...
        textonBox(2):textonBox(4),:));

    % Get texton outer area
    textonArea = textonFrame.*repmat(~textonMask,[1,1,3]);

    %
    % Find location
    %
    
    % Calculate energies
    Etexton = textonMapEnergy(newTextonMap, textonMapArea, textonClassAmount);
    Edistance = distanceEnergy(canvasMask, textonMask, classMask{textonClass});
    Earea = areaEnergy(canvas, canvasMask, textonArea, ~textonMask);

    % Combine energies
    E = Etexton + Edistance + Earea;
    
    % Decide on suitable location
    [maxValue,maxInd2] = max(E(:));
    [drawPoint(1),drawPoint(2)] = ind2sub(size(E),maxInd2);

    % Draw texton to image
    [canvas, canvasMask] = drawTexton(canvas, canvasMask, ...
        drawPoint, textonImage, textonMask);
    
    if verbose 
        subplot(2,4,2), subimage(uint8(canvas));
        title('Synthesized image');

        subplot(2,4,1), subimage(uint8(textonImage));
        title('Current Texton');
        axis image;

        subplot(2,4,5), imagesc(textonMapArea);
        title('Current Texton area');
        axis image;

        subplot(2,4,3), imagesc(Edistance);
        axis image
        set(gca,'Xlim',[0.5,newSize(2)+0.5])
        set(gca,'Ylim',[0.5,newSize(1)+0.5])        
        title('Energy: Distance');

        subplot(2,4,7), imagesc(Earea);
        axis image
        set(gca,'Xlim',[0.5,newSize(2)+0.5])
        set(gca,'Ylim',[0.5,newSize(1)+0.5])        
        title('Energy: Area');

        subplot(2,4,4), imagesc(Etexton);
        axis image
        set(gca,'Xlim',[0.5,newSize(2)+0.5])
        set(gca,'Ylim',[0.5,newSize(1)+0.5])                
        title('Energy: Texton');

        subplot(2,4,8), imagesc(E);
        axis image
        set(gca,'Xlim',[0.5,newSize(2)+0.5])
        set(gca,'Ylim',[0.5,newSize(1)+0.5])               
        title('Energy: Final');
        
        drawnow;
        if verbose > 1
            pause;
        end
    end        
end

textonImg = uint8(canvas);

%
% Image completion
%
canvas = completePoisson(canvas);
poissonImg = uint8(canvas);

%
% Post-production
%
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
subplot(2,3,6), imagesc(newTextonMap);
title('Synthesized texton map');
axis image



%         if isLastEffort
%             disp('Trying last effort!');
%             for classIter = 1:length(textons.classes);
%                 A = classMask{classIter}.*(~canvasMask);
%                 classPixelsLeft = sum(A(:));
%                 ind = find(classIndices == classIter);
%                 classSizes = sizes(ind);
%                 [vals,inds] = sort(classSizes);
% 
%                 pixelsCounter = 0;
%                 iter = 0;
%                 while pixelsCounter<(classPixelsLeft-100) && iter < length(vals)
%                     iter = iter + 1;
%                     pixelsCounter = pixelsCounter+vals(iter);
%                 end
%                 inds3 = ind(inds(1:iter));
%                 addLimit(inds3) = addLimit(inds3)+1;
%             end
%             isLastEffort = false;
%         else
%             isAddingTextons = false;
%         end

