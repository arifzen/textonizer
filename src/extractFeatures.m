function X = extractFeatures(lumImg, chrImg, filterBank)
%EXTRACTFEATURES Summary of this function goes here
%   Detailed explanation goes here

% Add Filterbanks features
X = applyFilterBank(lumImg, filterBank);

% Add Color features
if ~isempty(chrImg)
    temp = reshape(chrImg, numel(lumImg), 2);
    X = [X, temp];
end

% Add location features
%[U,V] = ind2sub(imgSize,(1:prod(imgSize))');
%X3 = [U,V];

% Normalize data
%Y1 = X  -(repmat(mean(X),size(X,1),1));
%X = Y1./(repmat(std(Y1),size(Y1,1),1));

%X(:,end-3:end) = X(:,end-3:end)*100;
