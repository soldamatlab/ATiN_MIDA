function [segmentation] = prepare_segmentation(mriSegmented)
segmentation = ft_datatype_segmentation(mriSegmented,'segmentationstyle','indexed');
if isfield(segmentation, 'seg')
elseif isfield(segmentation, 'tissue') % FT sometimes names it 'tissue'
    segmentation.seg = segmentation.tissue;
    segmentation = rmfield(segmentation, 'tissue');
else
    warning("Visualize: 'ft_datatype_segmentation' haven't produced a struct with either 'tissue' or 'seg' field. Segmentation won't be correctly visualized.")
end
end

