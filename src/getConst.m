function result = getConst(name)

switch(name)
    case 'ROOT'
        result = '..';
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
        result = fullfile(getConst('ROOT'),'in');
    otherwise
        assert(false);        
end        