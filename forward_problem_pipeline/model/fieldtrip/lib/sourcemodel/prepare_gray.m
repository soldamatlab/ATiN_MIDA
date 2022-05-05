function [segmentation] = prepare_gray(Config, segmentation)
check_required_field(Config, 'method');
check_required_field(Config, 'nLayers');

if strcmp(Config.method, 'mrtim')
    if Config.nLayers == 12
        segmentation.gray = segmentation.bgm | segmentation.cgm;
        segmentation = rmfield(segmentation, 'bgm');
        segmentation = rmfield(segmentation, 'cgm');
    end
elseif strcmp(Config.method, 'fieldtrip')
    if Config.nLayers == 3
        segmentation.gray = segmentation.brain;
        segmentation = rmfield(segmentation, 'brain');
    end
end
end
