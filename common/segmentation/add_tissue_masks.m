function [segmentation] = add_tissue_masks(Config, segmentation)
%% Config
if isfield(Config, 'label')
    label = Config.label;
elseif isfield(segmentation, 'tissuelabel')
    label = segmentation.tissuelabel;
else
    Config = check_tissue_function_config(Config);
    label = get_label(Config.method, Config.nLayers);
end

%% Add Masks
if ~isfield(segmentation, 'tissue')
    error("Cannot add tissue masks. No field 'tissue' found.")
end

for i = 1 : numel(label)
    segmentation.(label{i}) = segmentation.tissue == i;
end
segmentation.tissuelabel = label;
end

