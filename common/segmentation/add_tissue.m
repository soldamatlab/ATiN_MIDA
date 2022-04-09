function [segmentation] = add_tissue(Config, segmentation)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath([wd '/../']);

%% Config
Config = check_tissue_function_config(Config);

%% Add 'tissue' field
label = get_label(Config.method, Config.nLayers);
if ~isfield(segmentation, 'tissuelabel')
    segmentation.tissuelabel = label;
end

if ~isfield(segmentation, 'tissue')
    segmentation.tissue = zeros(size(segmentation.(label{1})));
    for i = 1 : numel(label)
        segmentation.tissue(segmentation.(label{i})) = i;
    end
end
end

