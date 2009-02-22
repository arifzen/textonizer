function E = crudeEnergy(textonFrame, crudeImg)

if false
    E = ssd(crudeImg, textonFrame);
else
    for k = 1:size(crudeImg,3)
        A = normxcorr2(textonFrame(:,:,3), crudeImg(:,:,3));
        if( k == 1 )
            E = 1/3*A;
        else
            E = E + 1/3*A;
        end;
    end

    E = E(size(textonFrame,1):size(crudeImg,1),size(textonFrame,2):size(crudeImg,2));
end
E = (E+1)./2;