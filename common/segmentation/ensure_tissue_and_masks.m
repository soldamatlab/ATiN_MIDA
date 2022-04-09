function [segmentation] = ensure_tissue_and_masks(Config, segmentation)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath([wd '/../']);

%% Config
check_required_field(Config, 'method')
check_required_field(Config, 'nLayers')

%%
label = get_label(Config.method, Config.nLayers);
if isfield(segmentation, label{1})
    if ~isfield(segmentation, 'tissue')
        segmentation = add_tissue(Config, segmentation);
    end
    return
end

if isfield(segmentation, 'tissue')
    segmentation.tissuelabel = label;
    segmentation = add_tissue_masks(Config, segmentation);
    return
end

if isfield(segmentation, 'seg')
    segmentation = assume_tissue(Config, segmentation, label, 'seg');
    return
end

if isfield(segmentation, 'anatomy')
    segmentation = assume_tissue(Config, segmentation, label, 'anatomy');
    return
end

error("Cannot add 'tissue' field and tissue masks. MRI doesn't contain either.")
end

