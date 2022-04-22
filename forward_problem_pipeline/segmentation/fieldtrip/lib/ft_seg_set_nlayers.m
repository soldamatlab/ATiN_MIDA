function [Config] = ft_seg_set_nlayers(Config)
SUPPORTED_NLAYERS = [3, 5];
DEFAULT_NLAYERS = 5;

if isfield(Config, 'nLayers')
    for i = 1:length(Config.nLayers)
        if ~ismember(Config.nLayers(i), SUPPORTED_NLAYERS)
            error("%d-layer segmentation not supported. Choose from 3 and 5.", Config.nLayers(i))
        end
    end
else
    Config.nLayers = DEFAULT_NLAYERS;
    warning("[nLayers] not set. Using default number of layers (%d).", DEFAULT_NLAYERS)
end
end

