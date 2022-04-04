function [seg, truth, label] = match_layers(Config, mriSegmented, groundTruth)
%% Config
check_required_field(Config, 'method');
check_required_field(Config, 'nLayers');

%% Call Matching Function
if Config.method == "fieldtrip"
    if Config.nLayers == 5
        [seg, truth, label] = match_layers_fieldtrip5(mriSegmented, groundTruth);
    elseif Config.nLayers == 3
        error("3-layer FieldTrip segmentation is not yet implemented.")
        [seg, truth, label] = match_layers_fieldtrip3(mriSegmented, groundTruth);
    else
        error("Only 5-layer and 3-layer FieldTrip segmentation is supported.")
    end
elseif Config.method == "mrtim"
    if Config.nLayers == 12
        error("12-layer MR-TIM segmentation is not yet implemented.")
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
end

