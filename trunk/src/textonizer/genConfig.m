experimentName = 'visual01';

config = [];

config.method = 'standard';

%config.gradient.max_iter = 1000;
%config.gradient.eta = 1e-8;
%config.gradient.weights.volume = -1e6;

config.visual.texton_clusters = 4;
config.visual.fb.orientations = pi/6;
config.visual.fb.scales = 4;

config.visual.filter_dim = 3;
config.visual.color_features = 'rgb';
config.visual.final_pca = true;

config.semantic.method = 'eran';

config.semantic.texton_per_class = 5;
config.semantic.texton_clusters = 3;
config.semantic.texton_amount_method = 'absolute';
config.semantic.min_texton_area = 100;
config.semantic.fill_holes = true;

%config.semantic.scales_amount = 10;
%config.semantic.window_sizes = [40 40];
%config.semantic.window_overlap = [0.5 0.5];

save(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');
