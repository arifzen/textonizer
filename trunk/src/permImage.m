function [newImg] = permImage(img)
% Perms an image

newImg = permImageRec(img,1+round(rand));


function [newImg] = permImageRec(img,dim)

if size(img,dim) <= 1
    newImg = img;
    return;
end

split = round(size(img,dim)/2);

S{1} = 1:split;
S{2} = split+1:size(img,dim);

perm = randperm(2);

newDim = (~(dim-1))+1;
T = cell(2,1);
for iter = 1:2

    if dim == 1
        T{iter} = permImageRec(img(S{iter},:), newDim);
    elseif dim == 2
        T{iter} = permImageRec(img(:,S{iter}), newDim);    
    else        
        assert(false);       
    end
end    

newImg = cat(dim,T{perm(1)},T{perm(2)});

