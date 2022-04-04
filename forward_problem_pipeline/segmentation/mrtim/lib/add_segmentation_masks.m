function [mriSegmented] = add_segmentation_masks(mriSegmented, nLayers)
%ADD_SEGMENTATION_MASKS
%   [nLayers] needs to be 6 or 12
%   (output of MR-TIM toolbox has 6 or 12 layers)
%
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
const_conductivity;

if nLayers == 6
    % TODO implement
    error("Conversion of 6 layer MR-TIM output is not yet implemented.");
    mriSegmented.(MRTIM_6_LABEL{1})  = mriSegmented.anatomy == 1;
    mriSegmented.(MRTIM_6_LABEL{2})  = mriSegmented.anatomy == 2;
    mriSegmented.(MRTIM_6_LABEL{3})  = mriSegmented.anatomy == 3;
    mriSegmented.(MRTIM_6_LABEL{4})  = mriSegmented.anatomy == 4;
    mriSegmented.(MRTIM_6_LABEL{5})  = mriSegmented.anatomy == 5;
    mriSegmented.(MRTIM_6_LABEL{6})  = mriSegmented.anatomy == 6;
end

if nLayers == 12
    mriSegmented.(MRTIM_12_LABEL{1})  = mriSegmented.anatomy == 1;
    mriSegmented.(MRTIM_12_LABEL{2})  = mriSegmented.anatomy == 2;
    mriSegmented.(MRTIM_12_LABEL{3})  = mriSegmented.anatomy == 3;
    mriSegmented.(MRTIM_12_LABEL{4})  = mriSegmented.anatomy == 4;
    mriSegmented.(MRTIM_12_LABEL{5})  = mriSegmented.anatomy == 5;
    mriSegmented.(MRTIM_12_LABEL{6})  = mriSegmented.anatomy == 6;
    mriSegmented.(MRTIM_12_LABEL{7})  = mriSegmented.anatomy == 7;
    mriSegmented.(MRTIM_12_LABEL{8})  = mriSegmented.anatomy == 8;
    mriSegmented.(MRTIM_12_LABEL{9})  = mriSegmented.anatomy == 9;
    mriSegmented.(MRTIM_12_LABEL{10}) = mriSegmented.anatomy == 10;
    mriSegmented.(MRTIM_12_LABEL{11}) = mriSegmented.anatomy == 11;
    mriSegmented.(MRTIM_12_LABEL{12}) = mriSegmented.anatomy == 12;
    return;
end

error("Unsupported number of layers. [nLayers] needs to be 6 or 12 as those are the possible outputs of MR-TIM toolbox.");
end

