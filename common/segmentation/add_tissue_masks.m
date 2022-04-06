function [segmentation] = add_tissue_masks(Config, segmentation)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath([wd '/../']);

%% Config
check_required_field(Config, 'method')
check_required_field(Config, 'nLayers')

%% Add Masks
if ~isfield(segmentation, 'tissue')
    error("Cannot add tissue masks. No field 'tissue' found.")
end

label = get_label(Config.method, Config.nLayers);
for i = 1 : numel(label)
    segmentation.(label{i}) = segmentation.tissue == i;
end
end

