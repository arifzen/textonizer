function Z = sad(X, Y)

for k=1:size(X,3),
    A = X(:,:,k);
    B = Y(:,:,k);

    ab = filter2(B, A, 'valid');

    if( k == 1 )
        Z = ab;
    else
        Z = Z + ab;
    end;
end;