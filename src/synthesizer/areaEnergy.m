function E = areaEnergy(canvas, area, areaMask)
           
[E, surveySizes] = ssdMask(canvas,area,canvasMask,areaMask);

%A = (exp(-distances)-0.5).*surveySizes - collisions;

end

