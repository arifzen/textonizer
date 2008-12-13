function X = extractFeatures(lumImg, chrImg, filterBank)
%EXTRACTFEATURES Summary of this function goes here
%   Detailed explanation goes here

% Add Filterbanks features
X = applyFilterBank(lumImg, filterBank);

% Dim reduction
options.ReducedDim = 3;

[EIGVECTOR, EIGVALUE, MEANDATA, NEW_DATA]=pca(X,options);
X = NEW_DATA;

% Add Color features
if ~isempty(chrImg)
    temp = reshape(lumImg, numel(lumImg), 1);
    X = [X, temp];    
    
    temp = reshape(chrImg, numel(lumImg), 2);
    X = [X, temp*2];    
end

% Add location features
%[U,V] = ind2sub(imgSize,(1:prod(imgSize))');
%X3 = [U,V];

% More PCA
[EIGVECTOR, EIGVALUE, MEANDATA, NEW_DATA]=pca(X);
X = NEW_DATA;

% Normalize data
%Y1 = X  -(repmat(mean(X),size(X,1),1));
%X = Y1./(repmat(std(Y1),size(Y1,1),1));

%X(:,end-3:end) = X(:,end-3:end)*100;
