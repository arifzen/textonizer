function [rgbImg, lumImg, chrImg] = factorizeImage(rgbImg)

if size(rgbImg,3) == 1
    lumImg = double(rgbImg);
    chrImg = [];
else
    if false
        temp = rgb2ntsc(rgbImg);
        lumImg = double(temp(:,:,1));
        chrImg = double(temp(:,:,2:3));
    else
        cform = makecform('srgb2lab');
        temp = double(applycform(rgbImg, cform));    
        lumImg = double(temp(:,:,1));
        chrImg = double(temp(:,:,2:3));
    end
end

