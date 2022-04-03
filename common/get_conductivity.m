function [conductivity, tissueLabel] = get_conductivity(method, nLayers)
addpath('./const');
const_conductivity;

if method == "fieldtrip"
    if nLayers == 5
        conductivity = FIELDTRIP_5;
        tissueLabel = FIELDTRIP_5_LABEL;
        return
    end
    error("Unsupported [nLayers]. Only [nLayers] = 5 is supported for segmentation [method] = 'fieldtrip'.")
end

if method == "mrtim"
    if nLayers == 6
        error("segmentation [method] = 'mrtim' and [nLayers] = 6 not yet implemented.")
        conductivity = MRTIM_6;
        tissueLabel = MRTIM_6_LABEL;
        return
    end
    if nLayers == 12
        conductivity = MRTIM_12;
        tissueLabel = MRTIM_12_LABEL;
        return
    end
    error("Unsupported [nLayers]. [nLayers] = 6 or 12 is supported for segmentation [method] = 'mrtim'.")
end

error("Unsupported segmentation [method]. 'get_conductivity' returns conductivity for 'fieldtrip' and 'mrtim' segmentation methods.")
end

