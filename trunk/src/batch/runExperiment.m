function runExperiment(experimentName)

% Load config and make room for results
load(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');
outputPath = fullfile(getConst('EXP_RESULT_PATH'), experimentName);
if ~exist(outputPath,'file')
    mkdir(outputPath);
end

inputPath = getConst('INPUT_PATH');

if isempty(config.batch.filenames)
    % Create list of images

    A = dir(fullfile(inputPath,'*.png'));
    filenames = {A.name};
else
    filenames = config.batch.filenames;
end

% Go over input images
for iter = 1:length(filenames)
    
    filename = filenames{iter};
    [pathstr, name] = fileparts(filename);
    
    outputFilename1 = fullfile(outputPath, [name,'_texton.png']);
    if(exist(outputFilename1, 'file'))
        continue;
    end

    outputFilename2 = fullfile(outputPath, [name,'_synth.png']);
    if(exist(outputFilename2, 'file'))
        continue;
    end
    
    % Load image
    img = imread(fullfile(inputPath,filename));
    
    fprintf('Textonizing: %s\n', name);
    
    [textons] = textonizer(img, config.textonizer, true);
    
    showTextonPatches(textons,5);
    
    scaleFactor = 0.8;
    set(gcf, 'PaperPosition', [0.25 2.5 scaleFactor*8 scaleFactor*6]);
    
    print('-painters','-dpng', outputFilename1);
    close(gcf);
       
    config.synthesizer.newSize = [size(img,1),size(img,2)].*config.batch.synth_scale;
    
    [newImg] = synthesizer(img, textons, config.synthesizer);
    
    imwrite(newImg,outputFilename2);
    
end
