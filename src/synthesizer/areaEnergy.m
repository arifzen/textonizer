function E = areaEnergy(canvas, canvasMask, textonArea, textonAreaMask)
     
% Get Distances and Significance of each measure (i.e. number of matching
% pixels).
[D, S] = ssdMask2(canvas,textonArea,canvasMask,textonAreaMask);
E = S.*D;
%E = exp(-D).*S;
E(isnan(E)) = 0;

end

%A = (exp(-distances)-0.5).*surveySizes - collisions;