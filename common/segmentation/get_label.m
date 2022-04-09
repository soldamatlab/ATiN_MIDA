function [label] = get_label(method, nLayers)
const_conductivity;

if method == "fieldtrip"
    if nLayers == 5
        label = FIELDTRIP_5_LABEL;
    elseif nLayers == 3
        label = FIELDTRIP_3_LABEL;
    else
        error("Only 5-layer and 3-layer FieldTrip segmentation is supported.")
    end
elseif method == "mrtim"
    if nLayers == 12
        label = MRTIM_12_LABEL;
    elseif nLayers == 6
        error("6-layer MR-TIM segmentation is not yet implemented.")
        label = MRTIM_6_LABEL;
    else
        error("Only 12-layer and 6-layer MR-TIM segmentation is supported.")
    end
elseif method == "SCI"
    label = SCI_LABEL;
else
    error("Only Fieldtrip and MR-TIM segmentation is implemented.")
end
end

