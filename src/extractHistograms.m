function [H, coord] = extractHistograms(textonMap, textonAmount, windowSize)
%EXTRACTHISTOGRAMS Summary of this function goes here
%   Detailed explanation goes here

% Sample windows
[windows, coord] = extractWindows(textonMap, windowSize(1), windowSize(2));
windowAmount = size(windows, 1);

% Convert to Histogram data
X = double(reshape(shiftdim(windows,1), prod(windowSize), windowAmount));
H = hist(X, textonAmount);

