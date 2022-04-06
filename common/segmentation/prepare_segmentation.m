function [segmentation] = prepare_segmentation(mriSegmented)
segmentation = ft_datatype_segmentation(mriSegmented,'segmentationstyle','indexed');
if isfield(segmentation, 'tissue')
elseif isfield(segmentation, 'seg') % FT sometimes names it 'seg'
    segmentation.tissue = segmentation.seg;
    segmentation = rmfield(segmentation, 'seg');
else
    warning("Visualize: 'ft_datatype_segmentation' haven't produced a struct with either 'tissue' or 'seg' field. Segmentation won't be correctly visualized.")
end
end

