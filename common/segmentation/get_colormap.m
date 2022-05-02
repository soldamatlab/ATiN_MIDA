function [colormap] = get_colormap(Config)
check_required_field(Config, 'method');
check_required_field(Config, 'nLayers');
const_color; % init 'Color' struct

colormap = [];
if strcmp(Config.method, 'fieldtrip')
    if Config.nLayers == 3
        colormap = Color.map.fieldtrip3;
    elseif Config.nLayers == 5
        colormap = Color.map.fieldtrip5;
    end
elseif strcmp(Config.method, 'mrtim')
    if Config.nLayers == 12
        colormap = Color.map.mrtim12;
    end
elseif strcmp(Config.method, 'SCI')
    if Config.nLayers == 8
        colormap = Color.map.sci8;
    end
end
end
