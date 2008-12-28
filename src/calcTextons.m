function [textonMap] = calcTextons(X, tClusterAmount, imgSize)
%CALCTEXTONS Summary of this function goes here
%   Detailed explanation goes here

% Cluster Textons
[clusterInd, centroids, sumD, D] = kmeans(X, ...
    tClusterAmount,'replicates',4,'EmptyAction','drop','start','cluster');

if numel(unique(clusterInd)) < tClusterAmount
    disp('!===Using kmeans with start uniform==!');
    [clusterInd, centroids, sumD, D] = kmeans(X, ...
        tClusterAmount,'replicates',4,'EmptyAction','drop','start','uniform');
end
% Build texton map
textonMap = reshape(clusterInd, imgSize);
