function [Z] = mapMatch(M,T,channels)
% Compare a map and a map's template

for k=1:channels,
    A = M==k;
    B = T==k;

    R = filter2(B, A, 'valid');

    if( k == 1 )
        Z = R;
    else
        Z = Z + R;
    end;
end;