function [segmentation] = add_tissue(Config, segmentation)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath([wd '/../']);

%% Config
check_required_field(Config, 'method')
check_required_field(Config, 'nLayers')

%% Add 'tissue' field
label = get_label(Config.method, Config.nLayers);
if ~isfield(segmentation, 'tissuelabel')
    segmentation.tissuelabel = label;
end

if isfield(segmentation, 'tissue')
    return
end
segmentation.tissue = zeros(size(segmentation.(label{1})));
for i = 1 : numel(label)
    segmentation.tissue(segmentation.(label{i})) = i;
end
end

