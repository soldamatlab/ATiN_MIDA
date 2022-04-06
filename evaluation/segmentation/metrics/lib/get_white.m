function [white] = get_white(Config, mriSegmented)
%% Check Config.part option
if isfield(Config, 'part')
    if ~(Config.method == "mrtim" && Config.nLayers == 12)
        warning("Ignoring 'Config.part'. Chosen mri segmentation does not segment white matter into multiple layers.")
    elseif ~(Config.part == "brain" || Config.part == "cerebrum")
            error("Config.part has to be 'brain', 'cerebrum' or left out.")
    end
end

%% Get White Mask
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
        if isfield(Config, 'part')
            if Config.part == "brain"
                white = bwm;
            elseif Config.part == "cerebrum"
                white = cwm;
            end
        else
            white = bwm | cwm;
        end
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
