%==========================================================================
% Chen Goldberg 	039571161
% Tovi Almozlino 	061201752
%==========================================================================
% PoissonCompletion - 
%   Main program.
%==========================================================================
function PoissonCompletion(inputFilename, lines)

[pathstr,name,ext,versn] = fileparts(inputFilename);
outputFilename = strcat('poi_', name, '.bmp');
outputIncompleteFilename= strcat('inc_', name, '.bmp');

% Create the partial image:
system(['LineSampling.exe "',inputFilename,'" ',num2str(lines),' "',outputIncompleteFilename,'"']);

% Read the partial image and begin actual poisson algorithm:
A=imread(outputIncompleteFilename);
B = completePoisson(A);

% Save final output:
imwrite(B,outputFilename);

%==========================================================================
% CompletePoisson - 
%   This is the actual algorithm.
%==========================================================================
function B = completePoisson(A)

%
% Initialization:
%
B = A;
imageWidth = size(A,2);
imageHeight = size(A,1);
imageChannels = size(A,3);
n = imageWidth*imageHeight;
nnz = 5*n;

%
% Pre-allocating:
%
veci(nnz) = 0;
vecj(nnz) = 0;
vecs(nnz) = 0;

%
% Init Black Matrix and black vectors -
% Holds information about location of black elements.
%
blackMatrix(imageHeight,imageWidth) = 0;
blacki(n) = 0;
blackj(n) = 0;
count = 1;
for i=1:imageHeight
    for j=1:imageWidth
        if(isBlackPixel(A,i,j))          
            blackMatrix(i,j) = count;
            blacki(count) = i;
            blackj(count) = j;
            count = count + 1;           
        else
            blackMatrix(i,j) = 0;
        end;
    end;
end;
blackn = count - 1;

%
% Build Matrix and Solutions:
%
b(blackn,imageChannels) = 0;
helper =  [
    0 ,-1;
    0 , 1;
    -1, 0;
    1 , 0];
count = 0;

% for each black pixel
for i=1:blackn

    % Get current black pixel's coordinates.
    x = blackj(i);
    y = blacki(i);

    currentValue = 0;

    % for each neighbor of the black pixel
    for direction=1:4

        % Get neighbour's coordinates.
        neighborX = x + helper(direction,1);
        neighborY = y + helper(direction,2);

        if((neighborX >= 1) && (neighborX <= imageWidth) && (neighborY >= 1) && (neighborY<=imageHeight))

            currentValue = currentValue - 1;

            if(blackMatrix(neighborY,neighborX) == 0) % i.e not black
                for channel=1:imageChannels
                    b(i,channel) = b(i,channel) - double(A(neighborY,neighborX,channel));
                end;
            else
                count = count + 1;
                veci(count) = i;
                vecj(count) = blackMatrix(neighborY,neighborX);
                vecs(count) = 1;
            end;
        end;
    end;

    count = count + 1;
    veci(count) = i;
    vecj(count) = i;
    vecs(count) = currentValue ;
end;

M = createSparse(veci,vecj,vecs,count,blackn);

% For each channel calculate a solution
for channel=1:imageChannels
    
    vecx = M\(b(:,channel));
    
    for i=1:blackn
        B(blacki(i),blackj(i),channel) = vecx(i);
    end;
end;

%==========================================================================
% createSparse - 
%   Returns a sparse matrix
%==========================================================================
function M = createSparse(veci,vecj,vecs,nnz,n)

    %
    % "Resize" vectors to create sparse matrix:
    %
    veci2(nnz) = 0;
    vecj2(nnz) = 0;
    vecs2(nnz) = 0;

    for i=1:nnz
        veci2(i) = veci(i);
        vecj2(i) = vecj(i);
        vecs2(i) = vecs(i);
    end;

    M = sparse(veci2,vecj2,vecs2,n,n);

%==========================================================================
% isBlackPixel - 
%   Check if a pixel in a given coordination is colored black.
%==========================================================================   
function isBlack = isBlackPixel(A,y,x)

isBlack = 1;

for j=1:size(A,3)
    isBlack = isBlack & A(y,x,j) == 0;
end
