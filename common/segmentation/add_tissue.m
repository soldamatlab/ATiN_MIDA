function [segmentation] = add_tissue(Config, segmentation)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath([wd '/../']);

%% Config
check_required_field(Config, 'method')
check_required_field(Config, 'nLayers')

%% Add 'tissue' field
if isfield(segmentation, 'tissue')
    return
end

label = get_label(Config.method, Config.nLayers);
segmentation.tissuelabel = label;
segmentation.tissue = zeros(size(segmentation.(label{1})));
for i = 1 : numel(label)
    segmentation.tissue(segmentation.(label{i})) = i;
end
end

