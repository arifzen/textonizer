function [textons] = textonizer(img, config, cache)

hash = dec2hex(round(sum(img(:))*...
    numel(img)*...
    sum(config.method)*...    
    config.visual.texton_clusters*...
    config.visual.fb.orientations*...
    sum(config.visual.color_features)*...
    config.visual.fb.scales+...
    config.visual.filter_dim+...
    config.visual.final_pca+...    
    sum(config.semantic.method)+...
    config.semantic.texton_per_class+...
    config.semantic.texton_clusters+...
    sum(config.semantic.texton_amount_method)+...
    config.semantic.min_texton_area+...;
    config.semantic.fill_holes));

fprintf('Textonizer data+config hash is: %s\n', hash); 

hashFilename = fullfile(...
    getConst('CACHE_PATH'),'textonizer',sprintf('%s.mat', hash));

if cache && exist(hashFilename,'file')
    disp('<Loading textons from cache>');
    load(hashFilename, 'textons');
else
    disp('Extracting textons');
    [textons] = textonizerActual(img, config, cache);
    save(hashFilename, 'textons');
end

function [textons] = textonizerActual(img, config, cache)
switch(config.method)
    case 'gradient'
        textons = gradientMethod(img, config);
        
    case 'standard'
        % Extract visual textons
        hash = dec2hex(round(sum(img(:))*...
            numel(img)*...
            config.visual.texton_clusters*...
            config.visual.fb.orientations*...
            sum(config.visual.color_features)*...
            config.visual.fb.scales+...
            config.visual.filter_dim+...
            config.visual.final_pca));
                
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
    otherwise
        assert(false);
end
