function runExperiment(experimentName)

% Setup batch pool
if matlabpool('SIZE')   
    matlabpool CLOSE;
else
    matlabpool OPEN 4;
end

% Load config and make room for results
temp = load(fullfile(getConst('EXP_CONFIG_PATH'), experimentName), 'config');
config = temp.config;

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

datas = cell(length(filenames),1);

% Go over input images
parfor iter = 1:length(filenames)
    
    currentConfig = config;
    filename = filenames{iter};
    [pathstr, name] = fileparts(filename);
    
    resultFilename = fullfile(outputPath, [name,'_data.mat']);
    textonMontageFilename = fullfile(outputPath, [name,'_texton.png']);
    newImageFilename = fullfile(outputPath, [name,'_synth.png']);    
    
    if(exist(resultFilename , 'file'))
        continue;
    end       
    
    % Load image
    img = imread(fullfile(inputPath,filename));
    
    fprintf('Textonizing: %s\n', name);
    
    [textons] = textonizer(img, currentConfig.textonizer, true);
    
    showTextonPatches(textons,5);
    
    scaleFactor = 0.8;
    set(gcf, 'PaperPosition', [0.25 2.5 scaleFactor*8 scaleFactor*6]);
    
    print('-painters','-dpng', textonMontageFilename);
    close(gcf);
       
    currentConfig.synthesizer.newSize = [size(img,1),size(img,2)].*currentConfig.batch.synth_scale;
    
    [newImg] = synthesizer(img, textons, currentConfig.synthesizer);
    
    imwrite(newImg,newImageFilename);
    
    % Save data results
    data = [];    
    data.filename = dataFilename;
    data.textons = textons;
    [status,data.svn_info] = system('svn info');    
    
    datas{iter} = data;
end

for iter = 1:length(filenames)
    data = datas{iter};
    save(data.filename,'data');
end