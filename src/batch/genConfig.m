experimentName = 'batch-12';

%
% Batch
%
config.batch.filenames = {...
    'stones.PNG',...    
    'eggs.PNG',...    
    'flowers.PNG',...    
    'Cantera1.PNG',...
    'Cantera2.PNG',...
    'Scagliola.PNG',...
    'birds.PNG',...
    'brick.PNG',...
    'droplets.PNG',...
    'fabric.PNG',...
    'fossil.PNG',...
    'lava.PNG',...
    'moss.PNG',...
    'olives.PNG',...
    'paintpeel.PNG',...
    'rustspots.PNG',...
    'stone.PNG',...
    'wetsand.PNG'};

% config.batch.filenames = {...
%     'eggs.PNG',...
%     'flowers.PNG',...
%     'stones.PNG'};

config.batch.synth_scale = [1 1];

%
% Textonizer
%
config.textonizer.method = 'standard';

config.textonizer.visual.texton_clusters = 4;
config.textonizer.visual.fb.orientations = pi/6;
config.textonizer.visual.fb.scales = 4;
config.textonizer.visual.filter_dim = 3;
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

config.synthesizer.weights.area = 1.3;
config.synthesizer.weights.texton = 0.4;
config.synthesizer.weights.crude = 0.25;
config.synthesizer.weights.ref = 1;
                
save(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');


%config.textonizer.gradient.max_iter = 1000;
%config.textonizer.gradient.eta = 1e-8;
%config.textonizer.gradient.weights.volume = -1e6;

%config.textonizer.semantic.scales_amount = 10;
%config.textonizer.semantic.window_sizes = [40 40];
%config.textonizer.semantic.window_overlap = [0.5 0.5];