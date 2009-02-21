function [Z,surveySizes] = ssdMask2(X, Y, Am, Bm)
% Perform SSD with respect to alpha values

K = ones(size(Y,1), size(Y,2));

for k=1:size(X,3),
    A = X(:,:,k);
    B = Y(:,:,k);

    a2 = filter2(K, A.^2, 'valid');
    b2 = sum(sum(B.^2));
    ab = filter2(B, A, 'valid');

    b2am = filter2(B.^2, ~Am, 'valid');
    a2bm = filter2(~Bm, A.^2, 'valid');

    if( k == 1 )
        Z = (1/k)*ab./(sqrt(a2).*sqrt(b2));
    else
        Z = Z + (1/k)*ab./(sqrt(a2).*sqrt(b2));
    end;
end;

surveySizes = filter2(Bm, Am, 'valid')./sum(Bm(:));

