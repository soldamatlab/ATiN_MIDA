function [seg1, seg2, label] = match_layers_REL(Config, segmentation1, segmentation2)
SAME_METHOD_ERROR = "Both segmentations' methods are the same. This should have been caught in 'match_layers.m'.";
MRTIM6_ERROR = "6-layer MR-TIM segmentation is not yet implemented.";

%% Call Matching Function
% to reduce number of 'if's for clarity
method1 = convert_method(Config.seg1);
method2 = convert_method(Config.seg2);

if method1 == "fieldtrip3"
    if method2 == "fieldtrip3"
        error(SAME_METHOD_ERROR)
    elseif method2 == "fieldtrip5"
        [seg1, seg2, label] = match_layers_FT3_FT5(segmentation1, segmentation2);
    elseif method2 == "mrtim6"
        error(MRTIM6_ERROR)
        [seg1, seg2, label] = match_layers_FT3_MT6(segmentation1, segmentation2);
    elseif method2 == "mrtim12"
        [seg1, seg2, label] = match_layers_FT3_MT12(segmentation1, segmentation2);
    end
elseif method1 == "fieldtrip5"
    if method2 == "fieldtrip3"
        [seg2, seg1, label] = match_layers_FT3_FT5(segmentation2, segmentation1);
    elseif method2 == "fieldtrip5"
        error(SAME_METHOD_ERROR)
    elseif method2 == "mrtim6"
        error(MRTIM6_ERROR)
        [seg1, seg2, label] = match_layers_FT5_MT6(segmentation1, segmentation2);
    elseif method2 == "mrtim12"
        [seg1, seg2, label] = match_layers_FT5_MT12(segmentation1, segmentation2);
    end
elseif method1 == "mrtim6"
    error(MRTIM6_ERROR)
    if method2 == "fieldtrip3"
        [seg2, seg1, label] = match_layers_FT3_MT6(segmentation2, segmentation1);
    elseif method2 == "fieldtrip5"
        [seg2, seg1, label] = match_layers_FT5_MT6(segmentation2, segmentation1);
    elseif method2 == "mrtim6"
        error(SAME_METHOD_ERROR)
    elseif method2 == "mrtim12"
        [seg1, seg2, label] = match_layers_MT6_MT12(segmentation1, segmentation2);
    end
elseif method1 == "mrtim12"
    if method2 == "fieldtrip3"
        [seg2, seg1, label] = match_layers_FT3_MT12(segmentation2, segmentation1);
    elseif method2 == "fieldtrip5"
        [seg2, seg1, label] = match_layers_FT5_MT12(segmentation2, segmentation1);
    elseif method2 == "mrtim6"
        error(MRTIM6_ERROR)
        [seg2, seg1, label] = match_layers_MT6_MT12(segmentation2, segmentation1);
    elseif method2 == "mrtim12"
        error(SAME_METHOD_ERROR)
    end
end
end

