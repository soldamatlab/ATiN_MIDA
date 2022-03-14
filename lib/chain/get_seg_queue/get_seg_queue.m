function [SegQueue] = get_seg_queue(segConfig, Segmentation)
warningMsg = "[mriSegmented] config has to be one of the following: 'all'; Name of a preceding segmentation module (i.e. 'fieldtrip'); Multiple module names in a cell array.";

cfgClass = class(segConfig);
if cfgClass == "char" || cfgClass == "string"
    stringConfig = true;
elseif cfgClass == "cell"
    stringConfig = false;
else
    warning(warningMsg)
    SegQueue = struct;
    return
end

if stringConfig
    if segConfig == "all"
        SegQueue = Segmentation;
    else
        SegQueue = get_single_seg(Segmentation, segConfig);
    end
else
    SegQueue = get_multiple_seg(Segmentation, segConfig);
end
end

