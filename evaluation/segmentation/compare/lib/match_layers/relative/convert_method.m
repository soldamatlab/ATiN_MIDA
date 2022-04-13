function [newMethod] = convert_method(Config)
%% Check if method is supported
if Config.method == "fieldtrip"
    if Config.nLayers == 5
    elseif Config.nLayers == 3
    else
        error("Only 5-layer and 3-layer FieldTrip segmentation is supported.")
    end
elseif Config.method == "mrtim"
    if Config.nLayers == 12
    elseif Config.nLayers == 6
    else
        error("Only 12-layer and 6-layer MR-TIM segmentation is supported.")
    end
else
    error("Only Fieldtrip and MR-TIM segmentation is implemented.")
end

%% Convert method
newMethod = [char(Config.method) num2str(Config.nLayers)];
end

