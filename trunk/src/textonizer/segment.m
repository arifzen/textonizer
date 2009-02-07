function [segLabel] = segment(img)
%SEGMENT Summary of this function goes here
%   Detailed explanation goes here

algType = 'norm-cut';

switch(algType)
    case 'norm-cut'
        [segLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,W,imageEdges]= NcutImage(img);
    otherwise
        error('No such alg!');
end
