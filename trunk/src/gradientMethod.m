function textons = gradientMethod(img, config)
%GRADIENTMETHOD Summary of this function goes here
%   Detailed explanation goes here

[rgbImg, lumImg, chrImg] = factorizeImage(img);

W(1) = config.gradient.weights.variance;
W(2) = config.gradient.weights.volume;
W = W./sum(W);

eta = config.gradient.eta;
maxIter = config.gradient.max_iter;

% Feature extraction
F = extractFeatures(img, config.visual);
imageSize = size(lumImg);
featureAmount = size(F,2);
pixelAmount = numel(lumImg);

% Texton channel extraction

N(1) = 1;
N(2) = 1;

ind = 1:pixelAmount;
channelIter = 1;
while true

    canvas = zeros(imageSize);
    X = rand(length(ind),1);
    X = X./sum(X);

    for i = 1:maxIter

        if true
            canvas(ind) = X;
            imagesc(canvas);            
            drawnow;
        end

        oldX = X;

        Gvariance = 0;
        for iter = 1:featureAmount
            I = F(ind, iter);
            Gvariance = Gvariance + I.*I - 2*I.*(I'*X);
        end
        Gvolume = 2.*X;
        
        G = W(1)*N(1)*Gvariance +...
            -W(2)*N(2)*Gvolume;

        X = X-eta*G;
        X = max(X,0);
       
        %X = X/sum(X);
        X = min(X,1);

        % Calculate energy function        
        Evariance = 0;
        for iter = 1:featureAmount
            I = F(ind, iter);
            Evariance = Evariance + I'.^2*X - (I'*X)^2;
        end
        Evolume = (X'*X);

        E = W(1)*N(1)*Evariance + ...
            W(2)*(1-N(2)*Evolume);
        
        % Check halt conditions
        dist = norm(X-oldX);

        %fprintf(' %.3f,',dist);
        %if mod(i,10) == 0
        %       fprintf('\n');
        %end
        %fprintf('Dist: %.3f, E: %f, Ratio:%g\n', dist, E,Evariance/Evolume);
        fprintf('E: %g %g\n', N(1)*Evariance, (1-N(2)*Evolume));

        if dist < 0.000001
              break
        end
    end
    
    % Channel Selection
    selectedPixels = ind(find(X > 0));
    ind = setdiff(ind, selectedPixels);
    
    channelMask = zeros(pixelAmount,1,'uint8');
    channelMask(selectedPixels) = 1;
    channelMask = reshape(channelMask, imageSize);
    
    channel = img .* repmat(channelMask,[1 1 3]);
    textons{channelIter}{1} = channel;
        
    if length(ind) < pixelAmount/10
        break;
    end
    channelIter = channelIter+1;
end

fprintf('\n');
