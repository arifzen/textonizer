function showTextonPatches(textonPatches, dispAmount)

if nargin < 2
    dispAmount = 10;
end

pClusterAmount = length(textonPatches.classes);

clf;
subplot(pClusterAmount, dispAmount, 1);

for pClusterIter = 1:pClusterAmount
    
    counter = 1;
    for tpIter = 1:min(length(textonPatches.classes{pClusterIter}), dispAmount)
        
        subImg = textonPatches.classes{pClusterIter}(tpIter).image;

        plotSub = sub2ind([dispAmount, pClusterAmount], counter, pClusterIter);

        subplot(pClusterAmount, dispAmount, plotSub);
        axis image;
        imgh = subimage(subImg);
        set(gca,'Visible','off');
        set(imgh,'alphaData',sum(subImg,3)>0);

        counter = counter + 1;
    end    
end
return;