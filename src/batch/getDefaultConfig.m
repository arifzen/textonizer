function config = getDefaultConfig()

%
% Textonizer
%
config.textonizer.method = 'standard';

config.textonizer.visual.texton_clusters = 4;
config.textonizer.visual.fb.orientations = pi/6;
config.textonizer.visual.fb.scales = 4;
config.textonizer.visual.filter_dim = 6;
config.textonizer.visual.color_features = 'ntsc';
config.textonizer.visual.final_pca = true;

config.textonizer.semantic.method = 'eran';
config.textonizer.semantic.texton_per_class = 5;
config.textonizer.semantic.texton_clusters = 3;
config.textonizer.semantic.texton_amount_method = 'threshold';
config.textonizer.semantic.min_texton_area = 25;
config.textonizer.semantic.fill_holes = false;

%
% Synthesizer
%
config.synthesizer.newSize = [];
config.synthesizer.method = 'map';
config.synthesizer.map.method = 'quilt';
config.synthesizer.map.quilt.dist.method = 'tile';
config.synthesizer.map.quilt.weights.spatial = 1;
config.synthesizer.map.quilt.weights.frequency = 0.5;

config.synthesizer.scales = [0.75,1];
config.synthesizer.candidates_max = 1;

config.synthesizer.weights.area = 0.3;
config.synthesizer.weights.texton = 0.4;
config.synthesizer.weights.crude = 0.25;
config.synthesizer.weights.ref = 1;

