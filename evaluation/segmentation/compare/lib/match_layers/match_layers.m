function [segmentation1, segmentation2] = match_layers(Config, segmentation1, segmentation2)
%% Config
check_required_field(Config, 'seg1');
check_required_field(Config.seg1, 'method');
check_required_field(Config.seg1, 'nLayers');

check_required_field(Config, 'seg2');
check_required_field(Config.seg2, 'method');
check_required_field(Config.seg2, 'nLayers');

%% Same Segmentation Method
if strcmp(Config.seg1.method, Config.seg2.method) && Config.seg1.nLayers == Config.seg2.nLayers
    segmentation1 = ensure_tissue_and_masks(Config.seg1, segmentation1);
    segmentation2 = ensure_tissue_and_masks(Config.seg2, segmentation2);
    return
end

%% Call Matching Function
if strcmp(Config.seg1.method, 'SCI')
    [seg2, seg1, label] = match_layers_SCI(Config.seg2, segmentation2, segmentation1);
elseif strcmp(Config.seg2.method, 'SCI')
    [seg1, seg2, label] = match_layers_SCI(Config.seg1, segmentation1, segmentation2);
else
    [seg1, seg2, label] = match_layers_REL(Config, segmentation1, segmentation2);
end

%% Replace tissue fields
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
