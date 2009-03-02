function [newImg] = tileImage(img, newSize)
% Tiles an image

newImg = nan(newSize);

for i = 1:ceil(size(newImg,1)./size(img,1))
    for j = 1:ceil(size(newImg,1)./size(img,1))
        i_from = (i-1).*size(img,1)+1;
        i_to = min(i_from + size(img,1)-1,newSize(1));
        i_size = i_to - i_from + 1;
        
        j_from = (j-1).*size(img,2)+1;
        j_to = min(j_from + size(img,2)-1,newSize(2));
        j_size = j_to - j_from + 1;
        
        newImg(i_from:i_to,j_from:j_to) = ...
            img(1:i_size,1:j_size);
    end
end
