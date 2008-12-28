experimentName = 'chen04';

config = [];

config.visual.texton_clusters = 4;
config.visual.fb.orientations = pi/6;
config.visual.fb.scales = 2;

config.semantic.method = 'chen';

config.semantic.texton_per_class = 5;

%config.semantic.texton_amount_method = 'absolute';
%config.semantic.min_texton_area = 100;
%config.semantic.fill_holes = true;

config.semantic.scales_amount = 10;
config.semantic.window_sizes = [25 25];
config.semantic.window_overlap = [0.5 0.5];

save(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');
