function [] = default_nlayers_warning(defaultNLayers, method)
warning("[nLayers] not provided. Assuming mri segmented by %s has %d layers.",...
    method, defaultNLayers)
end
