function E = distanceEnergy(canvasMask, templateMask, textonChannel)
% Keeps us from writing over existing pixels

%B = (0.1+0.5*exp(-0.1*bwdist(~classMask{textonClass}))).*classMask{textonClass};
%E = sad(B.*(~canvasMask),mask);

E = sad(textonChannel.*(~canvasMask),templateMask);

end

