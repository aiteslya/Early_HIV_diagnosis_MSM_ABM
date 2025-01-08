function config = create_config(type)
% function creates a configuration for an intervention depending on the
% type that was passed to it
% the function expects a string type and returns a structure config with
% the following fields "type": string, "upsilon_ahi1": double, "upsilon_ahi23": double,
% "upsilon_ahi45": double, "upsilon_ahi_c_6m": double

switch type
    case 'base'
        config.type = 'base';
        config.upsilon_ahi1 = 1;
        config.upsilon_ahi23 = 1;
        config.upsilon_ahi45 = 1;
        config.upsilon_ahi_c_6m = 1;
        config.upsilon_ahi_c_12m = 1;
    case 'max'
        config.type = 'max';
        config.upsilon_ahi1 = 365;
        config.upsilon_ahi23 = 365;
        config.upsilon_ahi45 = 365;
        config.upsilon_ahi_c_6m = 365;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_2'
        config.type = 'mult';
        config.upsilon_ahi1 = 2;
        config.upsilon_ahi23 = 2;
        config.upsilon_ahi45 = 2;
        config.upsilon_ahi_c_6m = 2;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_4'
        config.type = 'mult';
        config.upsilon_ahi1 = 4;
        config.upsilon_ahi23 = 4;
        config.upsilon_ahi45 = 4;
        config.upsilon_ahi_c_6m = 4;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_8'
        config.type = 'mult';
        config.upsilon_ahi1 = 8;
        config.upsilon_ahi23 = 8;
        config.upsilon_ahi45 = 8;
        config.upsilon_ahi_c_6m = 8;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_16'
        config.type = 'mult';
        config.upsilon_ahi1 = 16;
        config.upsilon_ahi23 = 16;
        config.upsilon_ahi45 = 16;
        config.upsilon_ahi_c_6m = 16;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_32'
        config.type = 'mult';
        config.upsilon_ahi1 = 32;
        config.upsilon_ahi23 = 32;
        config.upsilon_ahi45 = 32;
        config.upsilon_ahi_c_6m = 32;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_2_3m'
        config.type = 'mult';
        config.upsilon_ahi1 = 2;
        config.upsilon_ahi23 = 2;
        config.upsilon_ahi45 = 2;
        config.upsilon_ahi_c_6m = 1;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_4_3m'
        config.type = 'mult';
        config.upsilon_ahi1 = 4;
        config.upsilon_ahi23 = 4;
        config.upsilon_ahi45 = 4;
        config.upsilon_ahi_c_6m = 1;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_8_3m'
        config.type = 'mult';
        config.upsilon_ahi1 = 8;
        config.upsilon_ahi23 = 8;
        config.upsilon_ahi45 = 8;
        config.upsilon_ahi_c_6m = 1;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_16_3m'
        config.type = 'mult';
        config.upsilon_ahi1 = 16;
        config.upsilon_ahi23 = 16;
        config.upsilon_ahi45 = 16;
        config.upsilon_ahi_c_6m = 1;
        config.upsilon_ahi_c_12m = 1;
    case 'mult_32_3m'
        config.type = 'mult';
        config.upsilon_ahi1 = 32;
        config.upsilon_ahi23 = 32;
        config.upsilon_ahi45 = 32;
        config.upsilon_ahi_c_6m = 1; 
        config.upsilon_ahi_c_12m = 1;
    case 'mult_2_12m'
        config.type = 'mult';
        config.upsilon_ahi1 = 2;
        config.upsilon_ahi23 = 2;
        config.upsilon_ahi45 = 2;
        config.upsilon_ahi_c_6m = 2;
        config.upsilon_ahi_c_12m = 2;
    case 'mult_4_12m'
        config.type = 'mult';
        config.upsilon_ahi1 = 4;
        config.upsilon_ahi23 = 4;
        config.upsilon_ahi45 = 4;
        config.upsilon_ahi_c_6m = 4;
        config.upsilon_ahi_c_12m = 4;
    case 'mult_8_12m'
        config.type = 'mult';
        config.upsilon_ahi1 = 8;
        config.upsilon_ahi23 = 8;
        config.upsilon_ahi45 = 8;
        config.upsilon_ahi_c_6m = 8;
        config.upsilon_ahi_c_12m = 8;
    case 'mult_16_12m'
        config.type = 'mult';
        config.upsilon_ahi1 = 16;
        config.upsilon_ahi23 = 16;
        config.upsilon_ahi45 = 16;
        config.upsilon_ahi_c_6m = 16;
        config.upsilon_ahi_c_12m = 16;
    case 'mult_32_12m'
        config.type = 'mult';
        config.upsilon_ahi1 = 32;
        config.upsilon_ahi23 = 32;
        config.upsilon_ahi45 = 32;
        config.upsilon_ahi_c_6m = 32;    
        config.upsilon_ahi_c_12m = 32;
    case 'max_12m'
        config.type = 'max_12m';
        config.upsilon_ahi1 = 365;
        config.upsilon_ahi23 = 365;
        config.upsilon_ahi45 = 365;
        config.upsilon_ahi_c_6m = 365;
        config.upsilon_ahi_c_12m = 365;
    otherwise
        error('Wrong type of the configuration');
end

end