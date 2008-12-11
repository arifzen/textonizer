function showTextonPatches(textonPatches, dispAmount)

if nargin < 2
    dispAmount = 10;
end

pClusterAmount = length(textonPatches);

clf;
subplot(pClusterAmount, dispAmount, 1);

for pClusterIter = 1:pClusterAmount
    
    counter = 1;
    for tpIter = 1:min(length(textonPatches{pClusterIter}), dispAmount)
        
        subImg = textonPatches{pClusterIter}{tpIter};

        plotSub = sub2ind([dispAmount, pClusterAmount], counter, pClusterIter);

        subplot(pClusterAmount, dispAmount, plotSub);
        axis image;
        subimage(subImg);

        counter = counter + 1;
    end    
end