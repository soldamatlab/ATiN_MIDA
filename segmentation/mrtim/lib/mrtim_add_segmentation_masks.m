function [mriSegmented] = mrtim_add_segmentation_masks(mriSegmented, nLayers)
%MRTIM_TO_DATATYPE_SEGMENTATION
% [nLayers] needs to be 6 or 12 (output of MR-TIM toolbox has 6 or 12 layers)

%From MR-TIM documentation:
%anatomy_prepro_segment.nii: tissue classification image, with voxel values in the range 0 to 12
%(optionally, label -1 if Gap filling parameter was set to No)
%0:  background
%1:  brain gray matter (bGM)
%2:  cerebellar GM (cGM)
%3:  brain white matter (bWM)
%4:  cerebellar WM (cWM)
%5:  brainstem
%6:  cerebrospinal fluid (CSF)
%7:  skull - spongiosa
%8:  skull - compacta
%9:  muscle
%10: fat
%11: eyes
%12: skin
%-1: gap (no classification)

if nLayers == 6
    % TODO implement
    error("Conversion of 6 layer MR-TIM output is not yet implemented.");
end

if nLayers == 12
    mriSegmented.bgm       = mriSegmented.anatomy == 1;
    mriSegmented.cgm       = mriSegmented.anatomy == 2;
    mriSegmented.bwm       = mriSegmented.anatomy == 3;
    mriSegmented.cwm       = mriSegmented.anatomy == 4;
    mriSegmented.brainstem = mriSegmented.anatomy == 5;
    mriSegmented.csf       = mriSegmented.anatomy == 6;
    mriSegmented.spongiosa = mriSegmented.anatomy == 7;
    mriSegmented.compacta  = mriSegmented.anatomy == 8;
    mriSegmented.muscle    = mriSegmented.anatomy == 9;
    mriSegmented.fat       = mriSegmented.anatomy == 10;
    mriSegmented.eyes      = mriSegmented.anatomy == 11;
    mriSegmented.skin      = mriSegmented.anatomy == 12;
    return;
end

error("Unsupported number of layers. [nLayers] needs to be 6 or 12 as those are the possible outputs of MR-TIM toolbox.");
end

