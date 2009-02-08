function newImg = textonSynth(img, config, cache)

if nargin < 3
    selfTest();
    return;
end

[textons] = textonizer(img, config.textonizer, cache);
[newImg] = synthesizer(img, textons, config.synthesizer, cache);

function selfTest()

imageName = 'fossil.PNG';

textonConfig = load(fullfile(getConst('EXP_CONFIG_PATH'), 'visual01'), 'config');
config.textonizer = textonConfig.config;

img = loadImage(imageName);
newSize = size(img);
newSize = newSize(1:2)*1;

config.synthesizer = [];
config.synthesizer.newSize = newSize;

newImg = textonSynth(img, config, true);

clf;
subplot(1,2,1), subimage(img);
title('Original image');
subplot(1,2,2), subimage(newImg);
title('Synthesized image');
