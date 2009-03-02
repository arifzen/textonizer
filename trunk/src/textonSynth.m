function newImg = textonSynth(img, newSize, config, cache)

if nargin < 1
    selfTest();
    return;
end
if nargin < 2
    newSize = size(img);
    newSize = newSize(1:2);
end
if nargin < 3
    config = getDefaultConfig();
end
if nargin < 4
    cache = true;
end

if ~isempty(newSize)
    config.synthesizer.newSize = newSize;
end

[textons] = textonizer(img, config.textonizer, cache);
[newImg] = synthesizer(img, textons, config.synthesizer);

function selfTest()

imageName = 'eggs.PNG';

textonConfig = load(fullfile(getConst('EXP_CONFIG_PATH'), 'final-all-03'), 'config');
config.textonizer = textonConfig.config;

img = loadImage(imageName);
newSize = size(img);
newSize = newSize(1:2)*2;

config.synthesizer = [];
config.synthesizer.verbose = 1;
config.synthesizer.newSize = newSize;
config.synthesizer.method = 'map';
config.synthesizer.map.method = 'quilt';
config.synthesizer.map.quilt = [];
config.synthesizer.scales = [0.5,1];
config.synthesizer.candidates_max = 1;
config.synthesizer.weights.area = 0.5;
config.synthesizer.weights.texton = 0.25;
config.synthesizer.weights.crude = 0.25;
config.synthesizer.weights.ref = 1;
                
newImg = textonSynth(img, config, true);
