function [Config] = check_tissue_function_config(Config)
check_required_field(Config, 'method')
if Config.method == "SCI"
    Config.nLayers = 8;
else
    check_required_field(Config, 'nLayers')
end
end

