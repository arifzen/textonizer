function newTextonMap = synthTextonMap(textonMap, newSize, config)
% Synthesizes a new texton map

textonClassAmount = length(unique(textonMap(:)));
switch config.method;
    case 'tile'
        newTextonMap = textonMap;
    case 'quilt'
        tileSize = 40;
        Y = imagequilt(textonMap, tileSize, ceil(max(newSize)/(tileSize-round(tileSize / 6))));
        newTextonMap = Y(1:newSize(1),1:newSize(2),1);
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
