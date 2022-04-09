function [mriSegmented, groundTruth] = match_layers(Config, mriSegmented, groundTruth)
%% Config
check_required_field(Config, 'method');
check_required_field(Config, 'nLayers');

%% Call Matching Function
if Config.method == "fieldtrip"
    if Config.nLayers == 5
        [seg, truth, label] = match_layers_fieldtrip5(mriSegmented, groundTruth);
    elseif Config.nLayers == 3
        [seg, truth, label] = match_layers_fieldtrip3(mriSegmented, groundTruth);
    else
        error("Only 5-layer and 3-layer FieldTrip segmentation is supported.")
    end
elseif Config.method == "mrtim"
    if Config.nLayers == 12
        [seg, truth, label] = match_layers_mrtim12(mriSegmented, groundTruth);
    elseif Config.nLayers == 6
        error("6-layer MR-TIM segmentation is not yet implemented.")
        [seg, truth, label] = match_layers_mrtim6(mriSegmented, groundTruth);
    else
        error("Only 12-layer and 6-layer MR-TIM segmentation is supported.")
    end
else
    error("Only Fieldtrip and MR-TIM segmentation is implemented.")
end

%% Replace tissue fields
mriSegmented.tissue = seg;
groundTruth.tissue = truth;
mriSegmented.tissuelabel = label;
groundTruth.tissuelabel = label;

mriSegmented = remove_tissue_masks(Config, mriSegmented);
cfg = struct;
cfg.method = 'SCI';
groundTruth = remove_tissue_masks(cfg, groundTruth);

cfg = struct;
cfg.label = label;
mriSegmented = add_tissue_masks(cfg, mriSegmented);
groundTruth = add_tissue_masks(cfg, groundTruth);
end

