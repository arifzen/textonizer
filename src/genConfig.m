experimentName = 'test02';

config = [];

config.visual.texton_clusters = 4;
config.visual.fb.orientations = pi/6;
config.visual.fb.scales = 4;

config.semantic.method = 'eran';
config.semantic.texton_amount_method = 'absolute';
config.semantic.texton_per_class = 10;
config.semantic.min_texton_area = 100;
config.semantic.fill_holes = true;

save(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');
