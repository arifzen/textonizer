function [textons] = textonizer(img, config, cache)

% Extract visual textons
hash = dec2hex(round(sum(img(:))*...
    numel(img)*...
    config.visual.texton_clusters*...
    config.visual.texton_clusters*...
    config.visual.fb.orientations*...
    config.visual.fb.scales));

hashFilename = fullfile(...
    getConst('CACHE_PATH'),'visual',sprintf('%s.mat', hash));

if cache && exist(hashFilename,'file')
    disp('Loading visual textons from cache');
    load(hashFilename, 'textonMap');    
else
    disp('Extracting visual textons');
    [textonMap] = extractVisualTextons(img, config.visual);
    save(hashFilename, 'textonMap');
end

% Analyize
%showVisualTextonAnalysis(img, textonMap);
%pause;

% Extract semantic textons
disp('Extracting semantic textons');
[textons] = extractSemanticTextons(img, textonMap, config.semantic);

% Show textons
%disp('Displaying semantic textons');
%showTextonPatches(textons,5)
