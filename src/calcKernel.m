function [ kernel ] = calcKernel(windows)
%CALCKERNEL Summary of this function goes here
%   Detailed explanation goes here

windowSize = size(windows, 2)*size(windows, 3);
windowAmount = size(windows, 1);

% Convert 2d windows into 1d
X = double(reshape(shiftdim(windows,1), windowSize, windowAmount));

X = X./repmat(sqrt(sum(X.^2)),size(X,1),1);

% Normalize data

% Calc similarity
kernel = X'*X;

kernel = kernel - min(kernel(:));
kernel = kernel./max(kernel(:));
end
