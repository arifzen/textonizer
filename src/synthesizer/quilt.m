function [ Y ] = quilt(Y,confidence,X,tilesize)

X = double(X);

simple = 1;
err = 0.002;
overlap = round(tilesize / 6);

if( overlap >= tilesize )
    error('Overlap must be less than tilesize');
end;

nrow = ceil(size(Y,1)/(tilesize-overlap+1));
ncol = ceil(size(Y,2)/(tilesize-overlap+1));

for i=1:nrow
    for j=1:ncol
        startI = (i-1)*tilesize - (i-1) * overlap + 1;
        startJ = (j-1)*tilesize - (j-1) * overlap + 1;
        endI = min(startI + tilesize -1, size(Y,1));
        endJ = min(startJ + tilesize -1, size(Y,2));

        tilesizeR = endI-startI;
        tilesizeC = endJ-startJ;        
        
        %Determine the distances from each tile to the overlap region
        distances = ssd( X, Y(startI:endI, startJ:startJ+overlap-1, 1:3) );
        distances = distances(1:end-tilesize+overlap, 1:end-tilesize+overlap);

        %Find the best candidates for the match
        best = min(distances(:));
        candidates = find(distances(:) <= (1+err)*best);

        idx = candidates(ceil(rand(1)*length(candidates)));

        [sub(1), sub(2)] = ind2sub(size(distances), idx);
        fprintf( 'Picked tile (%d, %d) out of %d candidates.  Best error=%.4f\n', sub(1), sub(2), length(candidates), best );

        %If we do the simple quilting (no cut), just copy image
        if( simple )
            %Y(startI:endI, startJ:endJ, 1:3) = X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, 1:3);
            for r = 0:tilesizeR
                for c = 0:tilesizeC
                    target = [startI + r, startJ + c];
                    source = [sub(1) + r, sub(2) + c];

                    isBit = confidence(target(1),target(2));

                    if ~isBit
                        Y(target(1),target(2),:) = X(source(1),source(2),:);
                    end
                end
            end
        else

            %Initialize the mask to all ones
            M = ones(tilesize, tilesize);

            %We have a left overlap
            if( j > 1 )

                %Compute the SSD in the border region
                E = ( X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+overlap-1) - Y(startI:endI, startJ:startJ+overlap-1) ).^2;

                %Compute the mincut array
                C = mincut(E, 0);

                %Compute the mask and write to the destination
                M(1:end, 1:overlap) = double(C >= 0);
                %Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                %    X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :), M);

                %Y(startI:endI, startJ:endJ, 1:3) = X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, 1:3);

                %Compute the mask and write to the destination
                %                  M = zeros(tilesize, tilesize);
                %                  M(1:end, 1:overlap) = double(C == 0);
                %                  Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                %                      repmat(255, [tilesize, tilesize, 3]), M);

            end;

            %We have a top overlap
            if( i > 1 )
                %Compute the SSD in the border region
                E = ( X(sub(1):sub(1)+overlap-1, sub(2):sub(2)+tilesize-1) - Y(startI:startI+overlap-1, startJ:endJ) ).^2;

                %Compute the mincut array
                C = mincut(E, 1);

                %Compute the mask and write to the destination
                M(1:overlap, 1:end) = M(1:overlap, 1:end) .* double(C >= 0);
                %Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                %    X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :), M);
            end;


            if( i == 1 && j == 1 )
                Y(startI:endI, startJ:endJ, 1:3) = X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, 1:3);
            else
                %Write to the destination using the mask
                Y(startI:endI, startJ:endJ, :) = filtered_write(Y(startI:endI, startJ:endJ, :), ...
                    X(sub(1):sub(1)+tilesize-1, sub(2):sub(2)+tilesize-1, :), M);
            end;

        end;


        image(uint8(Y));
        drawnow;
    end;
end;

figure;
image(uint8(Y));

function y = myssd( x )
y = sum( x.^2 );

function A = filtered_write(A, B, M)
for i = 1:3,
    A(:, :, i) = A(:,:,i) .* (M == 0) + B(:,:,i) .* (M == 1);
end;
