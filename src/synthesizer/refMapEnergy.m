function E = refMapEnergy(newRefMap, textonIndex, textonMask)

E = mapMatch(newRefMap==textonIndex,textonMask,1)/numel(textonMask);
E = E.^2;

end

