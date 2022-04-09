function [segmentation] = add_tissue_masks(Config, segmentation)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath([wd '/../']);

%% Config
Config = check_tissue_function_config(Config);

%% Add Masks
if ~isfield(segmentation, 'tissue')
    error("Cannot add tissue masks. No field 'tissue' found.")
end

label = get_label(Config.method, Config.nLayers);
for i = 1 : numel(label)
    segmentation.(label{i}) = segmentation.tissue == i;
end
end

