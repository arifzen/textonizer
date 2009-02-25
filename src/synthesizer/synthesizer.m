function [newImg, newTextonMap, textonImg, poissonImg] = synthesizer(origImg, textons, config)

%
% Init
%
newImg = [];
if isfield(config,'verbose')
    verbose = config.verbose;
else
    verbose = 0;
end
textonClassAmount = length(textons.classes);
scales = config.scales;
maxCandidateAmount = config.candidates_max;

actualScale.origImg = origImg;
actualScale.origSize = [size(origImg,1),size(origImg,2)];
actualScale.newSize = config.newSize;
actualScale.textonMap = textons.map;

Warea = config.weights.area;
Wtexton = config.weights.texton;
Wcrude = config.weights.crude;
Wref = config.weights.ref;

counter = 0;
for textonClass = 1:length(textons.classes)
    counter = counter + length(textons.classes{textonClass});
end
textonAmount = counter;

actualScale.refMap = zeros(actualScale.origSize);
sizes = nan(1,textonAmount);
classIndices = nan(1,textonAmount);
textonIndices = nan(1,textonAmount);
counter = 0;
for textonClass = 1:length(textons.classes)
    for textonIter = 1:length(textons.classes{textonClass})
        counter = counter + 1;
        classIndices(counter) = textonClass;
        textonIndices(counter) = textonIter;
        actualScale.sizes(counter) = sum(textons.classes{textonClass}(textonIter).mask(:));
        
        A = [];
        M = textons.classes{textonClass}(textonIter).mask;
        [A(:,1),A(:,2)] = ind2sub(size(M),find(M));
        B = textons.classes{textonClass}(textonIter).box;
        C = A+repmat(B(1:2)-[1,1],size(A,1),1);
        I = sub2ind(size(actualScale.refMap),C(:,1),C(:,2));
        actualScale.refMap(I) = counter;
    end
end
clear A B C I;

%
% New Texton Map
%
[actualScale.newTextonMap, actualScale.newRefMap] = ...
    synthTextonMap(actualScale.textonMap, actualScale.newSize, ...
    config.map, actualScale.refMap);

if verbose
    clf;
    subplot(3,4,6), imagesc(actualScale.newTextonMap);
    title('Synthesized texton map');
    axis image
end

for scale = scales
    
    % Convert data to current scale
    newSize = round(actualScale.newSize*scale);
    origSize = round(actualScale.origSize*scale);
    newTextonMap = imresize(actualScale.newTextonMap, newSize, ...
        'method', 'nearest');
    newRefMap = imresize(actualScale.newRefMap, newSize, ...
        'method', 'nearest');
    
    refMap = imresize(actualScale.refMap, origSize, ...
        'method', 'nearest');
    origImg = imresize(actualScale.origImg, origSize, ...
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
            textonMasks{counter} = imresize(temp,scale,'method','nearest');
            
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
            
            sizes(counter) = sum(textonMasks{counter}(:));
        end
        classMask{textonClass} = logical(newTextonMap == textonClass);
    end
    
    textonMapHist = hist(newTextonMap(:),textonClassAmount);
    canvas = zeros([newSize 3]);
    canvasMask = logical(false(newSize));
    
    % See how many times each texton appears in the new reference
    B = hist(refMap(:),0:textonAmount);
    B(B == 0) = 1; % <- This might happen due to scaling issues.
    A = hist(newRefMap(:),0:textonAmount)./B;
    textonFrequencies = A(2:end);
    clear A B;
    
    if ~isempty(newImg)
        crudeImg = imresize(double(newImg),newSize,'method','bicubic');
        %verbose = 2;
    else
        crudeImg = [];
    end
    
    %
    % Texton adding
    %
    addCounter = zeros(1,textonAmount);
    addLimit = round(textonFrequencies);
    
    isAddingTextons = true;
    
    while isAddingTextons
        
        %
        % Find candidate textons
        %
        
        % Find current texton hist
        A = newTextonMap.*canvasMask;
        B = hist(A(:),0:textonClassAmount);
        currentTextonMapHist = B(2:end);
        textonCompletionRatio = currentTextonMapHist./textonMapHist;
        
        % Halt if no candidate left
        %         if all(textonCompletionRatio>0.9)
        %             isAddingTextons = false;
        %             continue;
        %         end
        
        Eclass = nan(size(sizes));
        for iter = 1:textonClassAmount
            Eclass(classIndices==iter) = 1-textonCompletionRatio(iter);
        end
        clear J I A B;
        
        %Evar = addLimit-addCounter;
        Evar = exp(-addCounter*10);
        Esizes = sizes;
        Efreq = max(addLimit-addCounter,0);
        
        TE = Efreq.*Eclass.*Esizes.*Evar;
        assert(all(TE>=0));
        
        if all(TE==0)
            isAddingTextons = false;
            continue;
        end
        
        %index = weightedSelect(E,true);
        
        [J,I] = sort(TE);
        J = J(end-maxCandidateAmount+1:end);
        I = I(end-maxCandidateAmount+1:end);
        candidates = I(J~=0);
        candidateAmount = length(candidates);
        clear I J;
        
        candidatePeakEnergy = nan(candidateAmount,1);
        candidatePeakLocation = nan(candidateAmount,2);
        
        for candidateIter = 1:candidateAmount
            
            index = candidates(candidateIter);
            
            %
            % Load candidate data
            %
            textonImage = textonImages{index};
            textonFrame = textonFrames{index};
            textonMask = textonMasks{index};
            textonMapArea = textonMapAreas{index};
            textonArea = textonAreas{index};
            
            %
            % Find best locations
            %
            
            % Calculate energies
            Etexton = textonMapEnergy(newTextonMap, textonMapArea, textonClassAmount);
            Edistance = distanceEnergy(canvasMask, textonMask, classMask{textonClass});
            Earea = areaEnergy(canvas, canvasMask, textonArea, ~textonMask);
            Eref = refMapEnergy(newRefMap, index, textonMask);
            if isempty(crudeImg)
                Ecrude = 0;
            else
                Ecrude = crudeEnergy(textonFrame, crudeImg);
            end
            
            % Combine energies
            E = (Warea*Earea + Wtexton*Etexton + ...
                Wcrude*Ecrude + Wref*Eref).*(Edistance.^2);
            
            % Decide on suitable location
            [maxValue,maxInd2] = max(E(:));
            [drawPoint(1),drawPoint(2)] = ind2sub(size(E),maxInd2);
            
            candidatePeakEnergy(candidateIter) = maxValue;
            candidatePeakLocation(candidateIter,:) = drawPoint;
        end
        
        %
        % Select best candidate
        %
        [J,I] = max(candidatePeakEnergy);
        index = candidates(I);
        drawPoint = candidatePeakLocation(I,:);
        
        textonImage = textonImages{index};
        textonMask = textonMasks{index};
        textonMapArea = textonMapAreas{index};
        
        fprintf('Selected candidate #%d with energy %g - TE: %g\n',I,J,norm(TE));
        clear I J;
        
        %
        % Register candidate
        %
        textonClass = classIndices(index);
        addCounter(index) = addCounter(index)+1;
        assert(addCounter(index)<=addLimit(index),'Added more textons than allowed!');
        
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
            
            subplot(3,4,8), imagesc(Eref);
            axis image
            set(gca,'Xlim',[0.5,newSize(2)+0.5])
            set(gca,'Ylim',[0.5,newSize(1)+0.5])
            title('Energy: Reference');
            
            subplot(3,4,12), imagesc(E);
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

