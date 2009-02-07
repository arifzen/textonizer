function [NH, coords] = extractHistograms(textonMap, textonAmount, ...
    windowSizes, windowOverlap)

%EXTRACTHISTOGRAMS Summary of this function goes here
%   Detailed explanation goes here

coords = [];
NH = [];

for sizeIter = 1:size(windowSizes,1)
    
    windowSize = windowSizes(sizeIter,:);
    
    % Sample windows
    [windows, coord] = extractWindows(textonMap, ...
        windowSize(1), windowSize(2), ...
        windowOverlap(1), windowOverlap(2));
    windowAmount = size(windows, 1);

    % Convert to Histogram data
    X = double(reshape(shiftdim(windows,1), prod(windowSize), windowAmount));

    % Calc histograms
    H = hist(X, textonAmount);
    
    % Normalize
    %NH = [NH, H./prod(windowSize)];
    NH = [NH, H];
    coords = [coords; coord];
end


