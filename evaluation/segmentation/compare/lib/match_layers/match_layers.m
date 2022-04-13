function [segmentation1, segmentation2] = match_layers(Config, segmentation1, segmentation2)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd))

%% Config
check_required_field(Config, 'seg1');
check_required_field(Config.seg1, 'method');
check_required_field(Config.seg1, 'nLayers');

check_required_field(Config, 'seg2');
SCI = false;
if isstring(Config.seg2) && Config.seg2 == "SCI"
    SCI = true;
else
    check_required_field(Config.seg2, 'method');
    check_required_field(Config.seg2, 'nLayers');
    if strcmp(Config.seg1.method, Config.seg2.method) && Config.seg1.nLayers == Config.seg2.nLayers
        return
    end
end

%% Call Matching Function
if SCI
    [seg1, seg2, label] = match_layers_SCI(Config.seg1, segmentation1, segmentation2);
elseif Config.seg2.method == "SCI"
    [seg1, seg2, label] = match_layers_SCI(Config.seg1, segmentation1, segmentation2);
elseif Config.seg1.method == "SCI"
    tmp = segmentation1;
    segmentation1 = segmentation2;
    segmentation2 = tmp;
    tmp = Config.seg1;
    Config.seg1 = Config.seg2;
    Config.seg2 = tmp;
    [seg1, seg2, label] = match_layers_SCI(Config.seg1, segmentation1, segmentation2);
else
    [seg1, seg2, label] = match_layers_REL(Config, segmentation1, segmentation2);
end

%% Replace tissue fields
if SCI
    Config.seg2 = struct;
    Config.seg2.method = 'SCI';
end

segmentation1.tissue = seg1;
segmentation2.tissue = seg2;
segmentation1.tissuelabel = label;
segmentation2.tissuelabel = label;

segmentation1 = remove_tissue_masks(Config.seg1, segmentation1);
segmentation2 = remove_tissue_masks(Config.seg2, segmentation2);

cfg = struct;
cfg.label = label;
segmentation1 = add_tissue_masks(cfg, segmentation1);
segmentation2 = add_tissue_masks(cfg, segmentation2);

end
