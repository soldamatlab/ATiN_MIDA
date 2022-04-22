function [Config] = set_visualize(Config)
inConfig = false;
if isfield(Config, 'visualize')
    if islogical(Config.visualize)
        visualize = Config.visualize;
        inConfig = true;
    end
end

if ~inConfig
    return
end

if isfield(Config, 'segmentation')
    if isfield(Config.segmentation, 'fieldtrip')
        Config.segmentation.fieldtrip.visualize = visualize;
    end
    if isfield(Config.segmentation, 'brainstorm')
        % TODO
    end
    if isfield(Config.segmentation, 'mrtim')
        Config.segmentation.mrtim.visualize = visualize;
    end
end

if isfield(Config, 'model')
    if isfield(Config.model, 'fieldtrip')
        Config.model.fieldtrip.visualize = visualize;
    end
    if isfield(Config.model, 'brainstorm')
        % TODO
    end
end

end

