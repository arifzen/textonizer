function [ kernel ] = calcKernel(windows)
%CALCKERNEL Summary of this function goes here
%   Detailed explanation goes here

windowSize = size(windows, 2)*size(windows, 3);
windowAmount = size(windows, 1);

% Convert 2d windows into 1d
X = double(reshape(shiftdim(windows,1), windowSize, windowAmount));

% Normalize data

% Calc similarity
kernel = X'*X;

end
