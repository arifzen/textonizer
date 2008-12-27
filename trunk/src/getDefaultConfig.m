function config = getDefaultConfig()

config = [];

config.visual.texton_clusters = 3;
config.visual.fb.orientations = pi/6;
config.visual.fb.scales = 4;

config.semantic.texton_amount_method = 'absolute';
config.semantic.texton_per_class = 10;
config.semantic.min_texton_area = 100;
config.semantic.fill_holes = true


