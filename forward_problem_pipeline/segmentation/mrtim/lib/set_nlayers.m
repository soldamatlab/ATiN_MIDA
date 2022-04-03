function [Config] = set_nlayers(Config)
SUPPORTED_NLAYERS = [6, 12];
DEFAULT_NLAYERS = 12;

setLayers = isfield(Config, 'nLayers');
mrtimLayers = isfield(Config, 'mrtim')...
            && isfield(Config.mrtim, 'run')...
            && isfield(Config.mrtim.run, 'tpmopt')...
            && isfield(Config.mrtim.run.tpmopt, 'tpmimg');

if setLayers
    if mrtimLayers
        warning("Number of layers was specified in both 'Config.nLayers' and 'Config.mrtim'. Config.nLayers (%d) will be used.", Config.nLayers)
    end
elseif mrtimLayers
    Config.nLayers = Config.mrtim.run.tpmopt.tpmimg;
else
    warning("Using default number of layers (%d).", DEFAULT_NLAYERS)
    Config.nLayers = DEFAULT_NLAYERS;
end

if ~ismember(Config.nLayers, SUPPORTED_NLAYERS)
    warning("Unsupported 'Config.nLayers' value. Using default number of layers (%d).", DEFAULT_NLAYERS)
    Config.nLayers = DEFAULT_NLAYERS;
end
end

