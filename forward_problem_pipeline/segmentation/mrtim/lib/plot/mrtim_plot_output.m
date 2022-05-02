function [] = mrtim_plot_output(Config)
%MRTIM_PLOT_OUTPUT Plots images from MR-TIM head tissue modelling outputs.
%   Requires FieldTrip toolbox to be added to path.
%   [outputPath] is path to the outputs of MR-TIM.
%   [imgPath] is path where plotted images are to be saved.
%   If [imgPath] is not passed, images are saved to 'outputPath\img'.

%% Create paths and folders
if ~isfield(Config, 'outputPath')
    error("'Config.outputPath' is required!")
end
outputPath = Config.outputPath;

tissueMasksPath = [outputPath '\tissue_masks'];

imgPath = [outputPath '\img']; % Default
if  isfield(Config, 'imgPath')
    imgPath = Config.imgPath;
end
if ~exist(imgPath, 'dir')
    if ~mkdir(imgPath)
        error("Could not create image folder!")
    end
end

masksImgPath = [imgPath '\tissue_masks'];
if ~exist(masksImgPath, 'dir')
    if ~mkdir(masksImgPath)
        error("Could not create mask image folder!")
    end
end

%% Set 'visualize'
visualize = true; % Default
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load MRI anatomy
if isfield(Config, 'mri')
    mri = Config.mri;
else    
    mri = ft_read_mri([outputPath '\anatomy_prepro.nii']);
end

%% Load segmented MRI
if isfield(Config, 'maskedMri')
    mriSegmented = Config.maskedMri;
else
    % Import 'mrtim_add_segmentation_masks'
    wd = fileparts(mfilename('fullpath')); % Only works in a script!
    addpath([wd '\..']);
    
    mriSegmented = ft_read_mri([outputPath '\anatomy_prepro_segment.nii']);
    mriSegmented = mrtim_add_segmentation_masks(mriSegmented, 12); % TODO implement 6 layers
end
segmentationIndexed = ft_datatype_segmentation(mriSegmented, 'segmentationstyle', 'indexed');

%% Plot segmented tissues
const_color; % init 'Color' struct
cfg = [];
cfg.colormap = Color.map.mrtim12;
cfg.location = 'center';
cfg.visualize = visualize;

cfg.save = [imgPath '\mri_segmented'];
plot_segmentation(cfg, segmentationIndexed);

cfg.save = [imgPath '\mri_segmented_anatomy'];
plot_segmentation(cfg, segmentationIndexed, mri);

%% Load and plot tissue masks
const_conductivity;
mrtim_plot_mask('bGM',  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask('cGM',  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask('bWM',  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask('cWM',  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask(MRTIM_12_LABEL{5},  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask('CSF',  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask(MRTIM_12_LABEL{7},  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask(MRTIM_12_LABEL{8},  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask(MRTIM_12_LABEL{9},  tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask(MRTIM_12_LABEL{10}, tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask(MRTIM_12_LABEL{11}, tissueMasksPath, masksImgPath, visualize)
mrtim_plot_mask(MRTIM_12_LABEL{12}, tissueMasksPath, masksImgPath, visualize)
end
