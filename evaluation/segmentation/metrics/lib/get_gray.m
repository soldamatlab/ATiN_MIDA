function [gray] = get_gray(Config, mriSegmented)
%% Check Config.part option
if isfield(Config, 'part')
    if ~(Config.method == "mrtim" && Config.nLayers == 12)
        warning("Ignoring 'Config.part'. Chosen mri segmentation does not segment gray matter into multiple layers.")
    elseif ~(Config.part == "brain" || Config.part == "cerebrum")
            error("Config.part has to be 'brain', 'cerebrum' or left out.")
    end
end

const_conductivity;
if Config.method == "fieldtrip"
    if Config.nLayers == 5
        gray = mriSegmented.(FIELDTRIP_5_LABEL{1});
    elseif Config.nLayers == 3
        error("3-layer FieldTrip segmentation does not distinguish white and gray matter.")
    else
        error("Only 5-layer and 3-layer FieldTrip segmentation is supported.")
    end
elseif Config.method == "mrtim"
    if Config.nLayers == 12
        bgm = mriSegmented.(MRTIM_12_LABEL{1});
        cgm = mriSegmented.(MRTIM_12_LABEL{2});
        gray = bgm | cgm;
        if isfield(Config, 'part')
            if Config.part == "brain"
                gray = bgm;
            elseif Config.part == "cerebrum"
                gray = cgm;
            end
        else
            gray = bgm | cgm;
        end
    elseif Config.nLayers == 6
        error("6-layer MR-TIM segmentation is not yet implemented.")
    else
        error("Only 12-layer and 6-layer MR-TIM segmentation is supported.")
    end
else
    error("Only Fieldtrip and MR-TIM segmentation is implemented.")
end
end
