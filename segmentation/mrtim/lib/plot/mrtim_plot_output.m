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
visualize = false; % Default
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load segmented MRI
if isfield(Config, 'maskedMri')
    mriSegmented = Config.maskedMri;
else
    % Import 'mrtim_add_segmentation_masks'
    wd = fileparts(mfilename('fullpath')); % Only works in a script!
    addpath([wd '\..']);
    
    mri = ft_read_mri([outputPath '\anatomy_prepro.nii']);
    mriSegmented = ft_read_mri([outputPath '\anatomy_prepro_segment.nii']);
    mriSegmented = mrtim_add_segmentation_masks(mriSegmented, 12); % TODO implement 6 layers
end
segmentationIndexed = ft_datatype_segmentation(mriSegmented, 'segmentationstyle', 'indexed');

%% Plot segmented tissues
cfg = [];
cfg.funparameter = 'anatomy';
cfg.funcolormap = [lines(6); prism(6); cool(1)];
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, segmentationIndexed);
print([imgPath '\mri_segmented'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Plot segmented tissues with MRI anatomy
cfg = [];
cfg.funparameter = 'tissue';
cfg.funcolormap = [lines(6); prism(6); cool(1)];
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, segmentationIndexed, mri);
print([imgPath '\mri_segmented_anatomy'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Load and plot tissue masks
plot_mask('bGM',       tissueMasksPath, masksImgPath, visualize)
plot_mask('brainstem', tissueMasksPath, masksImgPath, visualize)
plot_mask('bWM',       tissueMasksPath, masksImgPath, visualize)
plot_mask('cGM',       tissueMasksPath, masksImgPath, visualize)
plot_mask('compacta',  tissueMasksPath, masksImgPath, visualize)
plot_mask('CSF',       tissueMasksPath, masksImgPath, visualize)
plot_mask('cWM',       tissueMasksPath, masksImgPath, visualize)
plot_mask('eyes',      tissueMasksPath, masksImgPath, visualize)
plot_mask('fat',       tissueMasksPath, masksImgPath, visualize)
plot_mask('muscle',    tissueMasksPath, masksImgPath, visualize)
plot_mask('skin',      tissueMasksPath, masksImgPath, visualize)
plot_mask('spongiosa', tissueMasksPath, masksImgPath, visualize)
end
