function textonPatches = calcTextonPatches(rgbImg, coord, H, pClusterAmount)

% Cluster texton patches
[clusterInd, centroids, sumD, D] = kmeans(H', pClusterAmount, ...
    'replicates', 2,'EmptyAction', 'drop');

textonPatches = cell(pClusterAmount, 1);

for pClusterIter = 1:pClusterAmount
    
    pInd = find(clusterInd == pClusterIter)';    
       
    % Sort according do proximity to centroid
    [J,I] = sort(D(pInd,pClusterIter),1,'descend');
    pInd = pInd(I);

    textonPatches{pClusterIter} = cell(length(pInd), 1);
    counter = 1;
    for tpIter = pInd
        currentPatch = rgbImg(...
            coord(tpIter,1):coord(tpIter,2), ...
            coord(tpIter,3):coord(tpIter,4),:);
        
        textonPatches{pClusterIter}{counter} = currentPatch;
        counter = counter + 1;
    end    
end