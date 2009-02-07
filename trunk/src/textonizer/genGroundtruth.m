function genGroundtruth( filename )
%GENGROUNDTRUTH Summary of this function goes here
%   Detailed explanation goes here

% Load image
[rgbImg, lumImg, chrImg] = loadImage(filename);

while(true)
   
    [X,rect] = imcrop(rgbImg);close(gcf);

    q = input('1 to continue, 2 change texton, 3 save and exit');
    
    switch(q)
        case 1
            continue;
        case 2
            disp('next texton...');
        case 3
            break;
    end        
    
end
    