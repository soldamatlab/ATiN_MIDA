function [pos, dim] = prepare_sourcepos(segmentations)
nSegmentations = length(segmentations);
for s = 1:nSegmentations
    segmentations{s} = ft_convert_units(segmentations{s}, 'mm');
end
for s = 1:nSegmentations
    sNext = s + 1;
    if sNext > nSegmentations
        sNext = 1;
    end
    check_required_field(segmentations{s}, 'gray');
    sameDim = isequal(segmentations{s}.dim, segmentations{sNext}.dim);
    sameTransform = isequal(segmentations{s}.transform, segmentations{sNext}.transform);
    sameUnit = isequal(segmentations{s}.unit, segmentations{sNext}.unit);
    if ~(sameDim && sameTransform && sameUnit)
        error("Two or more segmentations do not share the same 'dim', 'transfrom' and/or 'unit' field.")
    end
end

graySeg = struct;
graySeg.dim = segmentations{1}.dim;
graySeg.transform = segmentations{1}.transform;
graySeg.unit = segmentations{1}.unit;
graySeg.gray = segmentations{1}.gray;
for s = 2:nSegmentations
    graySeg.gray = graySeg.gray | segmentations{s}.gray;
end

cfg = struct;
cfg.method = 'basedonmri';
cfg.unit = 'mm';
cfg.resolution = 6;
cfg.smooth = 'no';
cfg.mri = graySeg;
sourcemodel = ft_prepare_sourcemodel(cfg);
pos = sourcemodel.pos;
dim = sourcemodel.dim;
end
