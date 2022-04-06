function [white] = get_white(Config, mriSegmented)
const_conductivity;
if Config.method == "fieldtrip"
    if Config.nLayers == 5
        white = mriSegmented.(FIELDTRIP_5_LABEL{2});
    elseif Config.nLayers == 3
        error("3-layer FieldTrip segmentation does not distinguish white and gray matter.")
    else
        error("Only 5-layer and 3-layer FieldTrip segmentation is supported.")
    end
elseif Config.method == "mrtim"
    if Config.nLayers == 12
        bwm = mriSegmented.(MRTIM_12_LABEL{3});
        cwm = mriSegmented.(MRTIM_12_LABEL{4});
        white = bwm | cwm;
    elseif Config.nLayers == 6
        error("6-layer MR-TIM segmentation is not yet implemented.")
        [white] = get_white_mrtim6(mriSegmented);
    else
        error("Only 12-layer and 6-layer MR-TIM segmentation is supported.")
    end
else
    error("Only Fieldtrip and MR-TIM segmentation is implemented.")
end
end
