function [textonMap] = calcTextons(X, tClusterAmount, imgSize)
%CALCTEXTONS Summary of this function goes here
%   Detailed explanation goes here

% Cluster Textons
clusterInd = kmeans(X, tClusterAmount,'replicates',2,'EmptyAction','drop');

% Build texton map
textonMap = reshape(clusterInd, imgSize);
