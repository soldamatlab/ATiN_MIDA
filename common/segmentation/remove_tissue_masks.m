function [segmentation] = remove_tissue_masks(Config, segmentation)
if isfield(Config, 'label')
    label = Config.label;
else
    Config = check_tissue_function_config(Config);
    label = get_label(Config.method, Config.nLayers);
end

for l = 1:length(label)
    if isfield(segmentation, label{l})
        segmentation = rmfield(segmentation, label{l});
    end
end
end

