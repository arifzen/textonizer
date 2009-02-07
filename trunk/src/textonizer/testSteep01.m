
filename = 'synth.PNG';
inputPath = getConst('INPUT_PATH');
img = imread(fullfile(inputPath,filename));

[rgbImg, lumImg, chrImg] = factorizeImage(img);

maxIter = 1000;
eta = 1e-8;
Lvolume = 0;

%I = double(lumImg(:))/255;
% I = chrImg(:,:,1);
% I = I(:);
% J = chrImg(:,:,2);
% J = J(:);

config = [];
config.fb.orientations = pi/6;
config.fb.scales = 4;

config.filter_dim = 0;
config.color_features = 'ntsc';
config.final_pca = true;

F = extractFeatures(img, config);
featureAmount = size(F,2);

X = rand(prod(size(lumImg)),1);
X = (~FX>0).*X;
X = X./sum(X);

for i = 1:maxIter %global iterations,
%    plot(P);
    imagesc(reshape(X, size(lumImg)));    
    drawnow;
    
    oldX = X; 
        
    %grad = I.*I - 2*I.*(I'*X);
    grad = Lvolume*(2.*X);
    for iter = 1:featureAmount
        I = F(:, iter);
        grad = grad + I.*I - 2*I.*(I'*X);
    end
    
    X = X-eta*grad;
    X = max(X,0);    
    
    X = X/sum(X);
    %X = min(X,1);
    
%    P = P - min(P(:));
%    P = P./max(P(:));    
%    P = P./(ones(nd,1)*mean(P));      
%    P = P./(ones(nd,numnodes)*max(P(:)));  
%    alpha = 0.5;
%    P = (alpha).*P + (1-alpha).*(P./(ones(nd,1)*sum(P)));              
%    P = log(P+1);     
%    P = P./(ones(nd,1)*mean(P)*0.25);       
%    E = computerEnergy(K,P,tsmooth,G);
 
    %E = I'.^2*X - (I'*X)^2;
    E = Lvolume*(X'*X);
    for iter = 1:featureAmount
        I = F(:, iter);
        E = E + I'.^2*X - (I'*X)^2;
    end   
    
    dist = norm(X-oldX);
    
    %fprintf(' %.3f,',dist);
    %if mod(i,10) == 0
    %       fprintf('\n');
    %end
    fprintf('Dist: %.3f, E: %f\n', dist, E);
    
    %if dist < 0.000001
    %      break
    %end
end
fprintf('\n');
