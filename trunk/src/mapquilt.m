function [Y, newRefMap] = mapquilt(X, refMap, newSize, tilesize, overlap, err)

if ~nargin
    selfTest();
    return;
end

simple = 0;

if( nargin < 6 )
    err = 0.002;
end;
if( nargin < 5 )
    overlap = round(tilesize / 6);
end;
if( overlap >= tilesize )
    error('Overlap must be less than tilesize');
end;

channels = max(unique(X(:)));

n = ceil(max(newSize)/(tilesize-overlap));

destsize = n * tilesize - (n-1) * overlap;

Y = zeros(destsize, destsize, 1);
newRefMap = zeros(destsize, destsize, 1);

for i=1:n,
    for j=1:n,
        startI = (i-1)*tilesize - (i-1) * overlap + 1;
        startJ = (j-1)*tilesize - (j-1) * overlap + 1;
        endI = startI + tilesize -1 ;
        endJ = startJ + tilesize -1;
        
        %Determine the distances from each tile to the overlap region
        %This will eventually be replaced with convolutions
        distances = zeros( size(X,1)-tilesize, size(X,2)-tilesize );
        
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
        best = min(distances(:));
        candidates = find(distances(:) <= (1+err)*best);
        
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

figure;
imagesc(Y);

Y = Y(1:newSize(1),1:newSize(2),1);
newRefMap = newRefMap(1:newSize(1),1:newSize(2),1);

function A = filtered_write(A, B, M)
for i = 1:3,
    A(:, :, i) = A(:,:,i) .* (M == 0) + B(:,:,i) .* (M == 1);
end;

function selfTest()

imageName = 'eggs.PNG';

textonConfig = load(fullfile(getConst('EXP_CONFIG_PATH'), 'final-all-03'), 'config');
config.textonizer = textonConfig.config;

img = loadImage(imageName);
newSize = size(img);
newSize = newSize(1:2)*2;

config.synthesizer = [];
config.synthesizer.newSize = newSize;
config.synthesizer.method = 'map';
config.synthesizer.map.method = 'tile';

textons = textonizer(img, config.textonizer, true);

refMap = textons.map;
tilesize = 50;
[newTextonMap, newRefMap] = ...
    mapquilt(textons.map, refMap, newSize, tilesize,round(tilesize / 20));

