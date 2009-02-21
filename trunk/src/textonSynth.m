function newImg = textonSynth(img, config, cache)

if nargin < 3
    selfTest();
    return;
end

[textons] = textonizer(img, config.textonizer, cache);
[newImg] = synthesizer(img, textons, config.synthesizer);

function selfTest()

imageName = 'fabric.PNG';

textonConfig = load(fullfile(getConst('EXP_CONFIG_PATH'), 'final-all-03'), 'config');
config.textonizer = textonConfig.config;

img = loadImage(imageName);
newSize = size(img);
newSize = newSize(1:2);

config.synthesizer = [];
config.synthesizer.newSize = newSize;
config.synthesizer.method = 'map';
config.synthesizer.map.method = 'quilt';
newImg = textonSynth(img, config, true);
