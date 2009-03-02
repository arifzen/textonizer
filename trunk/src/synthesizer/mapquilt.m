function [Y, newRefMap] = mapquilt(X, refMap, newSize, config)

if ~nargin
    selfTest();
    return;
end
if ~isfield(config', 'error')
    config.error = 0.002;
end;
if ~isfield(config, 'titlesize')
    config.tilesize = 40;
end
if ~isfield(config, 'overlap')
    config.overlap = round(config.tilesize / 6);
end;
if ~isfield(config, 'simple')
    config.simple = 0;
end;
if ~isfield(config, 'weights')
    config.weights = [];
end;
if ~isfield(config.weights, 'spatial')
    config.weights.spatial = 1;
end;
if ~isfield(config.weights, 'frequency')
    config.weights.frequency = 1;
end;

overlap = config.overlap;
tilesize = config.tilesize;
err = config.error;
simple = config.simple;
Wspatial = config.weights.spatial;
Wfrequency = config.weights.frequency;

if(overlap >= tilesize )
    error('Overlap must be less than tilesize');
end;

channels = max(unique(X(:)));

n = ceil(max(newSize)/(tilesize-overlap));

destsize = n * tilesize - (n-1) * overlap;

Y = zeros(destsize, destsize, 1);
newRefMap = zeros(destsize, destsize, 1);

%
% Calc histogram matrix
%
origH = nan([size(X,1)-tilesize+1, size(X,2)-tilesize+1, channels]);
for iter = 1:channels
    origH(:,:,iter) = filter2(ones(tilesize),X==iter,'valid');       
end

% Create dist map
% distMap = nan(size(Y)); 
% for i=1:size(distMap,1)
%     for j=1:size(distMap,2)
%         distMap(i,j) = X(1+floor(rand*numel(X)));
%     end
% end

disp('Tiling Image');
distMap1 = tileImage(X, size(Y));
disp('Permutating Image');
distMap = permImage(distMap1);
assert(all(hist(distMap1(:),channels) == hist(distMap(:),channels)));

%A = hist(distMap(:), 1:channels)./hist(X(:), 1:channels);

newH = nan([size(Y,1)-tilesize+1, size(Y,2)-tilesize+1, channels]);
for iter = 1:channels
    newH(:,:,iter) = filter2(ones(tilesize),distMap==iter,'valid');       
end

for i=1:n,
    for j=1:n,
        startI = (i-1)*tilesize - (i-1) * overlap + 1;
        startJ = (j-1)*tilesize - (j-1) * overlap + 1;
        endI = startI + tilesize -1 ;
        endJ = startJ + tilesize -1;
                
        currentH = squeeze(newH(startI,startJ,:));
        for iter = 1:channels
            A = ((origH(:,:,iter) - currentH(iter)).^2)./(origH(:,:,iter) + currentH(iter));
            if iter == 1
                freqDistances = A;
            else
                freqDistances = freqDistances + A;
            end
        end        
        freqDistances = 0.5 * freqDistances;
        
        %Determine the distances from each tile to the overlap region
        %This will eventually be replaced with convolutions
        distances = zeros( size(X,1)-tilesize+1, size(X,2)-tilesize+1);
        
        %Compute the distances from the source to the left overlap region
        if( j > 1 )
            distances = mapDistance( X, Y(startI:endI, startJ:startJ+overlap-1, :), channels);
            distances = distances(1:end, 1:end-tilesize+overlap);
        end;
        
        %Compute the distance from the source to top overlap region
        if( i > 1 )
            Z = mapDistance( X, Y(startI:startI+overlap-1, startJ:endJ, :), channels);
            Z = Z(1:end-tilesize+overlap, 1:end);
            if( j > 1 ) 
                distances = distances + Z;
            else
                distances = Z;
            end;
        end;
        
        %If both are greater, compute the distance of the overlap
        if( i > 1 && j > 1 )
            Z = mapDistance(X, Y(startI:startI+overlap-1, startJ:startJ+overlap-1, :), channels);
            Z = Z(1:end-tilesize+overlap, 1:end-tilesize+overlap);
            distances = distances - Z;
        end;
        
        %Find the best candidates for the match
        %best = min(distances(:));       
        %candidates = find(distances(:) <= (1+err)*best);        
        %idx = candidates(ceil(rand(1)*length(candidates)));        
        %best = min(freqDistances(:));
        %candidates = find(freqDistances(:) <= (1+err)*best);        
        %idx = candidates(ceil(rand(1)*length(candidates)));
        
        Espatial = (min(distances(:))+1)./(distances(:)+1);
        Efrequency = (min(freqDistances(:))+1)./(freqDistances(:)+1);
        E = Espatial*Wspatial + Efrequency*Wfrequency;

        best = max(E(:));
        candidates = find(E(:) >= (1-err)*best);        
        idx = candidates(ceil(rand(1)*length(candidates)));
        
        [sub(1), sub(2)] = ind2sub(size(distances), idx);
        fprintf( 'Picked tile (%d, %d) out of %d candidates.  Best error=%.4f\n', sub(1), sub(2), length(candidates), best );
        
        %If we do the simple quilting (no cut), just copy image
        if( simple )
            Y(startI:endI, startJ:endJ, :) = X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :);
            newRefMap(startI:endI, startJ:endJ, :) = refMap(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :);
        else
            
            %Initialize the mask to all ones
            M = ones(tilesize, tilesize);
            
            %We have a left overlap
            if( j > 1 )
                
                %Compute the SSD in the border region
                E = (...
                    X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+overlap-1) - ...
                    Y(startI:endI, startJ:startJ+overlap-1)) > 0;
                
                %Compute the mincut array
                C = mincut(E, 0);
                
                %Compute the mask and write to the destination
                M(1:end, 1:overlap) = double(C >= 0);
            end
            
            %We have a top overlap
            if( i > 1 )
                %Compute the SSD in the border region
                E = (...
                    X(sub(1):sub(1)+overlap-1, sub(2):sub(2)+tilesize-1) - ...
                    Y(startI:startI+overlap-1, startJ:endJ)) > 0;
                
                %Compute the mincut array
                C = mincut(E, 1);
                
                %Compute the mask and write to the destination
                M(1:overlap, 1:end) = M(1:overlap, 1:end) .* double(C >= 0);
            end
            
            %Write to the destination using the mask
            Y(startI:endI, startJ:endJ, :) = ...
                Y(startI:endI, startJ:endJ, :).*(~M) + ...
                X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :).*M;

            newRefMap(startI:endI, startJ:endJ, :) = ...
                newRefMap(startI:endI, startJ:endJ, :).*(~M) + ...
                refMap(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :).*M;            
        end;        
        
        imagesc(Y);
        drawnow;
    end;
end;

%figure;
%imagesc(Y);

ratio = hist(Y(:),1:channels)./hist(X(:),1:channels);
disp('Frequency ratio between input and output is:');
disp(ratio)
fprintf('std: %g\n',std(ratio));

Y = Y(1:newSize(1),1:newSize(2),1);
newRefMap = newRefMap(1:newSize(1),1:newSize(2),1);

if false
    clf;
    subplot(1,3,1), imagesc(X);
    title('Source texton map');
    axis image;

    subplot(1,3,2), imagesc(distMap(1:newSize(1),1:newSize(2),1));
    title('Target distribution map');
    axis image;

    subplot(1,3,3), imagesc(Y);
    title('Target texton map');
    axis image;
        
    scaleFactor = 0.8;
    set(gcf, 'PaperPosition', [0.25 2.5 scaleFactor*8 scaleFactor*4]);    
    print('-painters','-dpng', ...
        fullfile(getConst('FIGURE_PATH'),...
        sprintf('textonMap%d',round(rand*10000))));    
    close(gcf);
        
%     subplot(3,4,3), imagesc(Edistance);
%     axis image
%     set(gca,'Xlim',[0.5,newSize(2)+0.5])
%     set(gca,'Ylim',[0.5,newSize(1)+0.5])
%     title('Energy: Distance');
% 
%     subplot(3,4,7), imagesc(Earea);
%     axis image
%     set(gca,'Xlim',[0.5,newSize(2)+0.5])
%     set(gca,'Ylim',[0.5,newSize(1)+0.5])
%     title('Energy: Area');       
end

function A = filtered_write(A, B, M)
for i = 1:3,
    A(:, :, i) = A(:,:,i) .* (M == 0) + B(:,:,i) .* (M == 1);
end;

function selfTest()

imageName = 'stones.PNG';

textonConfig = load(fullfile(getConst('EXP_CONFIG_PATH'), 'final-all-03'), 'config');
config.textonizer = textonConfig.config;

img = loadImage(imageName);
newSize = size(img);
newSize = newSize(1:2)*1    ;

config.synthesizer = [];
config.synthesizer.newSize = newSize;
config.synthesizer.method = 'map';
config.synthesizer.map.method = 'tile';

textons = textonizer(img, config.textonizer, true);

refMap = textons.map;
config.tilesize = 60;
config.overlap = round(config.tilesize/6);
config.simple = 0;
config.weights.spatial = 0.5;
config.weights.frequency = 0.5;

[newTextonMap, newRefMap] = ...
    mapquilt(textons.map, refMap, newSize, config);

