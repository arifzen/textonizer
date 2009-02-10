function newImg = textonSynth(img, config, cache)

if nargin < 3
    selfTest();
    return;
end

[textons] = textonizer(img, config.textonizer, cache);
[newImg] = synthesizer(img, textons, config.synthesizer, cache);

function selfTest()

imageName = 'fossil.png';

textonConfig = load(fullfile(getConst('EXP_CONFIG_PATH'), 'visual02'), 'config');
config.textonizer = textonConfig.config;

img = loadImage(imageName);
newSize = size(img);
newSize = newSize(1:2)*2;

config.synthesizer = [];
config.synthesizer.newSize = newSize;
config.synthesizer.method = 'sparse';
newImg = textonSynth(img, config, true);
