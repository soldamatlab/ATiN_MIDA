function [Config] = set_visualize(Config)
inConfig = false;
if isfield(Config, 'miscellaneous')
    if isfield(Config.miscellaneous, 'visualize')
        if isboolean(Config.miscellaneous.visualize)
            visualize = Config.miscellaneous.visualize;
            inConfig = true;
        end
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
    if isfield(Config.segmentation, 'fieldtrip')
        
    end
    if isfield(Config.segmentation, 'brainstorm')
        % TODO
    end
end

end

