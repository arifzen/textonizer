function [textons] = extractSemanticTextons(img, textonMap, config)
    %EXTRACTSEMANTICTEXTONS Summary of this function goes here
    %   Detailed explanation goes here

    switch(config.method)
        case 'eran'
            textons = eranMethod(img, textonMap, config);
        case 'chen'
            textons = chenMethod(img, textonMap, config);
        otherwise
            assert(false);
    end
end