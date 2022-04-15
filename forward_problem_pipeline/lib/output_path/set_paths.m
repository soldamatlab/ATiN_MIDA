function [Config] = set_paths(Config)
if isfield(Config, 'segmentation')
    segmentationPath = [Config.output '\segmentation'];
    if isfield(Config.segmentation, 'fieldtrip')
        Config.segmentation.fieldtrip.output = segmentationPath;
    end
    if isfield(Config.segmentation, 'mrtim')
        Config.segmentation.mrtim.output = segmentationPath '\mrtim';
    end
end
if isfield(Config, 'model')
    modelPath = [Config.output '\model'];
    if isfield(Config.model, 'fieldtrip')
        Config.model.fieldtrip.output = [modelPath '\fieldtrip'];
    end
end
end

