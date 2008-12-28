experimentName = 'chen14-coloronly';

config = [];

config.visual.texton_clusters = 6;
config.visual.fb.orientations = pi/6;
config.visual.fb.scales = 4;

config.visual.filter_dim = 0;
config.visual.color_features = 'rgb';
config.visual.final_pca = false;

config.semantic.method = 'chen';

config.semantic.texton_per_class = 5;
config.semantic.texton_clusters = 3;
%config.semantic.texton_amount_method = 'absolute';
%config.semantic.min_texton_area = 100;
%config.semantic.fill_holes = true;

config.semantic.scales_amount = 10;
config.semantic.window_sizes = [40 40];
config.semantic.window_overlap = [0.5 0.5];

save(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');
