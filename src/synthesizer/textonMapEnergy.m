function E = textonMapEnergy(textonMap, areaTextonMap, textonClassAmount)

E = mapMatch(textonMap, areaTextonMap, textonClassAmount)/numel(areaTextonMap);

end

