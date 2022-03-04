function [mriSegmented] = load_mri_segmented(Config)
SegmentedData = load(Config.mriSegmented.path);
if isfield(SegmentedData, 'mriSegmented')
    mriSegmented = SegmentedData.mriSegmented;
else
    error("File in 'Config.mriSegmented.path' does not contain variable named 'mriSegmented'.")
end
end

