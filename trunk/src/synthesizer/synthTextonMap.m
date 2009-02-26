function [newTextonMap, newRefMap] = synthTextonMap(textonMap, newSize, config, refMap)
% Synthesizes a new texton map

textonClassAmount = length(unique(textonMap(:)));
switch config.method;
    case 'tile'
        newTextonMap = textonMap;
        newRefMap = refMap;
    case 'quilt'
        quiltConfig = config.quilt;
        quiltConfig.tilesize = (max(newSize)^0.5)*4;
        
        [newTextonMap, newRefMap] = ...
            mapquilt(textonMap, refMap, newSize, quiltConfig);        
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
