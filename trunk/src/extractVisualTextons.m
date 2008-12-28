function [textonMap] = extractVisualTextons(img, config)
    %EXTRACTVISUALTEXTONS Summary of this function goes here
    %   Detailed explanation goes here

    imageSize = [size(img,1),size(img,2)];

    % Extract features
    X = extractFeatures(img, config);

%     A = reshape(X, [imageSize,3]);
%     B = A - min(A(:));
%     C = B/max(B(:));
%     imshow(C);

    % Calc textons
    textonMap = calcTextons(X, config.texton_clusters, imageSize);

    %showTextons(filterBank, centroids);
    %showTextonMap(textonMap);
    %pause;
    %showTextonChannels(rgbImg, textonMap);
    %pause;
