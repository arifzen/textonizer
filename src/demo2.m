clusters = 6;
if false
end
% Create filter bank
para = design_filter_bank(pi/8,3);
filterBank = create_gabor_filter_bank(para);

% Load image
origImg = loadImage('gavish.jpg');
img = rgb2ntsc(origImg);
if size(img,3) == 1
    lumImg = img;
else
    lumImg = rgb2gray(img);
end

img = double(img);
lumImg = double(lumImg);

imgSize = size(lumImg);

% Apply filters
featureAmount = length(filterBank) + 3;

X1 = zeros(prod(imgSize),length(filterBank));

for iter=1:length(filterBank)    
    %filteredImg = normxcorr2(real(filterBank{iter}),lumImg);
    %filteredImg = conv2(lumImg, filterBank{iter}, 'same');
    filteredImg = abs(imfilter(lumImg, filterBank{iter}, 'symmetric'));
    
    imagesc(real(filteredImg));
    colormap('gray');
    drawnow;
    %pause;
    X1(:,iter)= filteredImg(:);
end

% Add Color feature
if size(img,3) == 1
    X2 = reshape(img,prod(imgSize),1);
else    
    X2 = reshape(img(:,:,2:3),prod(imgSize),2);
end

%[U,V] = ind2sub(imgSize,(1:prod(imgSize))');
%X3 = [U,V];

X = [real(X1),X2];


% Normalize data
%Y1 = X  -(repmat(mean(X),size(X,1),1));
%X = Y1./(repmat(std(Y1),size(Y1,1),1));

%X(:,end-3:end) = X(:,end-3:end)*100;

% Cluster
[clusterInd, centroids] = kmeans(X,clusters,'replicates',2);

% Build texton filters
% S = zeros(100,100);
% for iter = 1:length(filterBank)
%     Si = real(filterBank{iter});
%     padSize = round(([100,100]-size(Si))/2);
%     
%     Si = padarray(Si,padSize);
%     S = S+Si;
% end;

% Build texton map
textonMap = reshape(clusterInd, imgSize);
imagesc(textonMap);
drawnow;

%% Show texton channels
subplot(1,clusters+1,1);
axis image;
subimage(origImg);
for iter = 1:clusters
    subplot(1,clusters+1,iter+1);
    axis image;
    subimage(origImg.*repmat(uint8(textonMap == iter),[1 1 3]));
end