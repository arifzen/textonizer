function X = extractFeatures(img, config)
    %EXTRACTFEATURES Summary of this function goes here
    %   Detailed explanation goes here

    [rgbImg, lumImg, chrImg] = factorizeImage(img);

    hash = dec2hex(round(sum(lumImg(:))*...
        numel(lumImg)*...
        config.fb.orientations*...
        config.fb.scales));

    hashFilename = fullfile(...
        getConst('CACHE_PATH'),'visual',sprintf('%s.mat', hash));

    if exist(hashFilename,'file')
        disp('[Loading filter bank response from cache]');
        load(hashFilename, 'X');
    else
        % Create filter bank
        para = design_filter_bank(config.fb.orientations, config.fb.scales);
        filterBank = create_gabor_filter_bank(para);

        % Add Filterbanks features
        X = applyFilterBank(lumImg, filterBank);
        save(hashFilename, 'X');
    end

    % Dim reduction
    if config.filter_dim
        options.ReducedDim = config.filter_dim;    
        [EIGVECTOR, EIGVALUE, MEANDATA, NEW_DATA]=pca(X,options);
        X = NEW_DATA;
    end
    
    % Add Color features
    switch(config.color_features)
        case 'none'
        case 'rgb'
            temp = reshape(double(rgbImg)/255, numel(lumImg), 3);
            X = [X, temp];        
        case 'ntsc'
            if ~isempty(chrImg)
                %temp = reshape(lumImg, numel(lumImg), 1);
                %X = [X, temp];
                temp = reshape(chrImg, numel(lumImg), 2);
                X = [X, temp];
            end
        otherwise                    
    end    

    % Add location features
    %[U,V] = ind2sub(imgSize,(1:prod(imgSize))');
    %X3 = [U,V];

    % More PCA

    if config.final_pca
        [EIGVECTOR, EIGVALUE, MEANDATA, NEW_DATA]=pca(X);
        X = NEW_DATA;
    end
    
    % Normalize data
    %Y1 = X  -(repmat(mean(X),size(X,1),1));
    %X = Y1./(repmat(std(Y1),size(Y1,1),1));

    %X(:,end-3:end) = X(:,end-3:end)*100;
    
end