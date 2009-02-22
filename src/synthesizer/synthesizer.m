function newImg = synthesizer(origImg, textons, config)

%
% Init
%
newImg = [];
verbose = 1;
textonClassAmount = length(textons.classes);
scales = [0.25,0.5,1];
%scales = [1];

actualScale.origImg = origImg;
actualScale.origSize = size(origImg);
actualScale.newSize = config.newSize;
actualScale.textonMap = textons.map;

counter = 0;
for textonClass = 1:length(textons.classes)
    counter = counter + length(textons.classes{textonClass});
end
textonAmount = counter;

sizes = nan(1,textonAmount);
classIndices = nan(1,textonAmount);
textonIndices = nan(1,textonAmount);
counter = 0;
for textonClass = 1:length(textons.classes)
    for textonIter = 1:length(textons.classes{textonClass})
        counter = counter + 1;
        classIndices(counter) = textonClass;
        textonIndices(counter) = textonIter;
        sizes(counter) = sum(textons.classes{textonClass}(textonIter).mask(:));
    end
end

%
% New Texton Map
%
actualScale.newTextonMap = synthTextonMap(actualScale.textonMap, ...
    actualScale.newSize, config.map);

if verbose
    clf;
    subplot(3,4,6), imagesc(actualScale.newTextonMap);
    title('Synthesized texton map');
    axis image
end

for scale = scales

    % Convert data to current scale
    newSize = round(actualScale.newSize*scale);
    newTextonMap = imresize(actualScale.newTextonMap, newSize, ...
        'method', 'nearest');
    origImg = imresize(actualScale.origImg, newSize, ...
        'method', 'bicubic');

    %
    % Preprocessing
    %
    counter = 0;
    classMask = cell(textonClassAmount,1);
    textonImages = cell(textonAmount,1);
    textonFrames = cell(textonAmount,1);
    textonMasks = cell(textonAmount,1);
    textonMapAreas = cell(textonAmount,1);
    textonAreas = cell(textonAmount,1);

    for textonClass = 1:length(textons.classes)
        for textonIter = 1:length(textons.classes{textonClass})
            counter = counter + 1;

            % Get texton image
            temp = double(textons.classes{textonClass}(textonIter).image);
            textonImages{counter} = imresize(temp,scale,'method','bicubic');

            % Get texton mask
            temp = textons.classes{textonClass}(textonIter).mask;
            textonMasks{counter} = imresize(temp,scale,'method','bicubic');

            % Get texton map area
            textonBox = textons.classes{textonClass}(textonIter).box;
            temp = actualScale.textonMap(...
                textonBox(1):textonBox(3),...
                textonBox(2):textonBox(4));
            textonMapAreas{counter} = imresize(temp,scale,'method','nearest');

            % Get texton frame
            temp = double(actualScale.origImg(...
                textonBox(1):textonBox(3),...
                textonBox(2):textonBox(4),:));
            textonFrames{counter} = imresize(temp,scale,'method','bicubic');
            textonAreas{counter} = textonFrames{counter}.*...
                repmat(~textonMasks{counter},[1,1,3]);

        end
        classMask{textonClass} = logical(newTextonMap == textonClass);
    end

    canvas = zeros([newSize 3]);
    canvasMask = logical(false(newSize));

    if ~isempty(newImg)
        crudeImg = imresize(double(newImg),newSize,'method','bicubic');
        verbose = 2;        
    else
        crudeImg = [];
    end
    
    %
    % Texton adding
    %
    addCounter = zeros(1,textonAmount);
    addLimit = ones(1,textonAmount)*1;
    isAddingTextons = true;    
    currentClass = 1;
    
    while isAddingTextons

        % Select candidate texton
        weights = (addLimit-addCounter).*(sizes);
        weights2 = weights.*(classIndices==currentClass);
        index = weightedSelect(weights2,true);
    
        if currentClass~=textonClassAmount
            currentClass = currentClass+1;
        else
            currentClass = 1;
        end
        
        
        % Halt if no candidate left
        if isempty(index) || weights(index)==0
            isAddingTextons = false;
            continue;
        end

        %
        % Register candidate
        %
        textonClass = classIndices(index);
        addCounter(index) = addCounter(index)+1;
        assert(addCounter(index)<=addLimit(index),'Added more textons than allowed!');

        %
        % Load candidate data
        %
        textonImage = textonImages{index};
        textonFrame = textonFrames{index};
        textonMask = textonMasks{index};
        textonMapArea = textonMapAreas{index};
        textonArea = textonAreas{index};

        %
        % Find location
        %
        
        % Calculate energies
        if ~isempty(crudeImg)
            %Ecrude = crudeEnergy(textonFrame, crudeImg);
            Edistance = distanceEnergy(canvasMask, textonMask, classMask{textonClass});
            %Etexton = textonMapEnergy(newTextonMap, textonMapArea, textonClassAmount);
            %Earea = areaEnergy(canvas, canvasMask, textonArea, ~textonMask);
            Ecrude = 1-ssd2(crudeImg, textonImage, textonMask);
            % Combine energies
            %E = (0.5*Earea + 0.75*Etexton + 0.25*Ecrude).*(Edistance.^2);
            E = (1*Ecrude).*(Edistance.^2);
        else
            Etexton = textonMapEnergy(newTextonMap, textonMapArea, textonClassAmount);
            Edistance = distanceEnergy(canvasMask, textonMask, classMask{textonClass});
            Earea = areaEnergy(canvas, canvasMask, textonArea, ~textonMask);

            % Combine energies
            %E = Etexton + Edistance + Earea;
            E = (1*Earea+1*Etexton).*(Edistance.^2);
        end

        % Decide on suitable location
        [maxValue,maxInd2] = max(E(:));
        [drawPoint(1),drawPoint(2)] = ind2sub(size(E),maxInd2);

        % Draw texton to image
        [canvas, canvasMask] = drawTexton(canvas, canvasMask, ...
            drawPoint, textonImage, textonMask);

        if verbose
            subplot(3,4,2), subimage(uint8(canvas));
            title('Synthesized image');

            subplot(3,4,1), subimage(uint8(textonImage));
            title('Current Texton');
            axis image;

            subplot(3,4,5), imagesc(textonMapArea);
            title('Current Texton area');
            axis image;

            subplot(3,4,3), imagesc(Edistance);
            axis image
            set(gca,'Xlim',[0.5,newSize(2)+0.5])
            set(gca,'Ylim',[0.5,newSize(1)+0.5])
            title('Energy: Distance');

            subplot(3,4,7), imagesc(Earea);
            axis image
            set(gca,'Xlim',[0.5,newSize(2)+0.5])
            set(gca,'Ylim',[0.5,newSize(1)+0.5])
            title('Energy: Area');

            subplot(3,4,4), imagesc(Etexton);
            axis image
            set(gca,'Xlim',[0.5,newSize(2)+0.5])
            set(gca,'Ylim',[0.5,newSize(1)+0.5])
            title('Energy: Texton');

            subplot(3,4,8), imagesc(E);
            axis image
            set(gca,'Xlim',[0.5,newSize(2)+0.5])
            set(gca,'Ylim',[0.5,newSize(1)+0.5])
            title('Energy: Final');

            if ~isempty(crudeImg)
                subplot(3,4,9), subimage(uint8(crudeImg));
                title('Crude Image');

                subplot(3,4,11), imagesc(Ecrude);
                axis image
                set(gca,'Xlim',[0.5,newSize(2)+0.5])
                set(gca,'Ylim',[0.5,newSize(1)+0.5])
                title('Energy: Crude');
            end
            
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
    if ~all(canvasMask(:))
        canvas = completePoisson(canvas);        
    end
	poissonImg = uint8(canvas);

    newImg = uint8(canvas);
end

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

