function runExperiment(experimentName)
%RUNEXPRIMENT Summary of this function goes here
%   Detailed explanation goes here

    % Load config and make room for results
    load(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');
    outputPath = fullfile(getConst('EXP_RESULT_PATH'), experimentName);
    if ~exist(outputPath,'file')
        mkdir(outputPath);
    end

    % Create list of images
    inputPath = getConst('INPUT_PATH');
    A = dir(fullfile(inputPath,'*.png'));
    filenames = {A.name};

    % Go over input images
    for iter = 1:length(filenames)

        filename = filenames{iter};
        [pathstr, name] = fileparts(filename);

        outputFilename = fullfile(outputPath, [name,'.png']);
        if(exist(outputFilename, 'file'))
            continue;
        end

        % Load image
        img = imread(fullfile(inputPath,filename));

        fprintf('Textonizing: %s\n', name);
        textons = textonizer(img, config, false);

        showTextonPatches(textons,5);

        scaleFactor = 0.8;
        set(gcf, 'PaperPosition', [0.25 2.5 scaleFactor*8 scaleFactor*6]);

        print('-dpng', outputFilename);
        close(gcf);
    end
end