function [newTextonMap, newRefMap] = synthTextonMap(textonMap, newSize, config, refMap)
% Synthesizes a new texton map

textonClassAmount = length(unique(textonMap(:)));
switch config.method;
    case 'tile'
        newTextonMap = textonMap;
        newRefMap = refMap;
    case 'quilt'
        tileSize = 40;
        [newTextonMap, newRefMap] = ...
            mapquilt(textonMap, refMap, newSize, tileSize);        
    otherwise
        assert(false,'Bad map method!');
end

figure;
imagesc(newTextonMap);
origHist = hist(textonMap(:),1:textonClassAmount);
newHist = hist(newTextonMap(:),1:textonClassAmount);

disp(origHist);
disp(newHist);
pause(1);
close(gcf);
