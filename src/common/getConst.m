function result = getConst(name)

rootPath = fullfile(fileparts(mfilename('fullpath')),'..','..');

switch(name)
    case 'ROOT'
        result = rootPath;
    case 'LIB_PATH'
        result = fullfile(rootPath,'lib');
    case 'SRC_PATH'
        result = fullfile(rootPath,'src');        
    case 'DATA_PATH'
        result = fullfile(getConst('ROOT'),'data');
    case 'CACHE_PATH'        
        result = fullfile(getConst('DATA_PATH'),'cache');
    case 'EXP_PATH'        
        result = fullfile(getConst('DATA_PATH'),'experiments');
    case 'EXP_CONFIG_PATH'
        result = fullfile(getConst('EXP_PATH'),'configurations');
    case 'EXP_RESULT_PATH'
        result = fullfile(getConst('EXP_PATH'),'results');
    case 'INPUT_PATH'
        result = fullfile(getConst('DATA_PATH'),'inputs');
    case 'FIGURE_PATH'
        result = fullfile(getConst('DATA_PATH'),'figures');
    otherwise
        assert(false);        
end        