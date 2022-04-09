function [mriSegmented, groundTruth, groundTruthAnatomy] = align_empirical(Config)
mriSegmented = Config.mriSegmented;
groundTruth = Config.groundTruth;
groundTruthAnatomy = Config.groundTruthAnatomy;

%% Fix Transform Matrices (for plotting)
% Fix flips and permutations of axis (works for FieldTrip and MR-TIM):
if Config.mriSegmented.method == "fieldtrip"
    mriSegmented.transform = eye(4);
    groundTruth.transform = eye(4);
    groundTruthAnatomy.transform = eye(4);
elseif Config.mriSegmented.method == "mrtim"
    %mriSegmented.transform(2,:) = -mriSegmented.transform(2,:);
    mriSegmented.transform(2,4) = mriSegmented.transform(2,4)+3; % manually tried
    mriSegmented.transform(3,4) = mriSegmented.transform(3,4)-13; % manually tried
else % Default transformation
    warning("Segmentation methods other than FieldTrip and MR-TIM not tested. Applying default transformation to segmentation. Segmentation may not align with ground truth.")
    mriSegmented.transform(2,:) = -mriSegmented.transform(2,:);
end

%% Fix Tissue Masks
mriSegmented = add_tissue(Config.mriSegmented, mriSegmented);
mriSegmented.tissue = flip(mriSegmented.tissue, 2);
mriSegmented = add_tissue_masks(Config.mriSegmented, mriSegmented);
end

