function [mriSegmented] = format_segmented_mri(mriSegmented, segmentationMethod, nLayers)
if segmentationMethod == "fieldtrip"
    return
end

if segmentationMethod == "mrtim"
    mriSegmented = mrtim_to_datatype_segmentation(mriSegmented, nLayers);
    return
end

error('Unsupported [segmentationMethod]. Supproted methods are "fieldtrip" and "mrtim".')
end

