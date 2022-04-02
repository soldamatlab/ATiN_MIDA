function [Config] = set_paths(Config)
if isfield(Config, 'segmentation')
    segmentationPath = [Config.outputPath '\segmentation'];
    if isfield(Config.segmentation, 'fieldtrip')
        Config.segmentation.fieldtrip.path.output = [segmentationPath '\fieldtrip'];
    end
    if isfield(Config.segmentation, 'mrtim')
        Config.segmentation.mrtim.path.output = [segmentationPath '\mrtim'];
    end
end
if isfield(Config, 'model')
    modelPath = [Config.outputPath '\model'];
    if isfield(Config.model, 'fieldtrip')
        Config.model.fieldtrip.path.output = [modelPath '\fieldtrip'];
    end
end
end

