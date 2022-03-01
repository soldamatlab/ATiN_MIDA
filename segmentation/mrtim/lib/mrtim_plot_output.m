function [] = mrtim_plot_output(outputPath, imgPath)
%MRTIM_PLOT_OUTPUT Plots images from MR-TIM head tissue modelling outputs.
%   Requires FieldTrip toolbox to be added to path.
%   [outputPath] is path to the outputs of MR-TIM.
%   [imgPath] is path where plotted images are to be saved.
%   If [imgPath] is not passed, images are saved to 'outputPath\img'.

%% Create paths
tissueMasksPath = [outputPath '\tissue_masks'];

if  ~exist('imgPath', 'var');
    imgPath = [outputPath '\img'];
end
masksPath = [imgPath '\tissue_masks'];

%% Load segmented MRI
mri = ft_read_mri([outputPath '\anatomy_prepro.nii']);
mri_segmented = ft_read_mri([outputPath '\anatomy_prepro_segment.nii']);

mri_segmented.bgm = mri_segmented.anatomy == 1;
mri_segmented.cgm = mri_segmented.anatomy == 2;
mri_segmented.bwm = mri_segmented.anatomy == 3;
mri_segmented.cwm = mri_segmented.anatomy == 4;
mri_segmented.brainstem = mri_segmented.anatomy == 5;
mri_segmented.csf = mri_segmented.anatomy == 6;
mri_segmented.spongiosa = mri_segmented.anatomy == 7;
mri_segmented.compacta = mri_segmented.anatomy == 8;
mri_segmented.muscle = mri_segmented.anatomy == 9;
mri_segmented.fat = mri_segmented.anatomy == 10;
mri_segmented.eyes = mri_segmented.anatomy == 11;
mri_segmented.skin = mri_segmented.anatomy == 12;

seg_i = ft_datatype_segmentation(mri_segmented, 'segmentationstyle', 'indexed');

%% Plot segmented tissues
cfg = [];
cfg.funparameter = 'anatomy';
cfg.funcolormap = [lines(6); prism(6); cool(1)];
cfg.location = 'center';
ft_sourceplot(cfg, seg_i);
print([imgPath '\mri_segmented'],'-dpng','-r300')

%% Plot segmented tissues with MRI anatomy
cfg = [];
cfg.funparameter = 'tissue';
cfg.funcolormap = [lines(6); prism(6); cool(1)];
cfg.location = 'center';
ft_sourceplot(cfg, seg_i, mri);
print([imgPath '\mri_segmented_anatomy'],'-dpng','-r300')

%% Load tissue masks
bGM = ft_read_mri([tissueMasksPath '\bGM.nii']);
brainstem = ft_read_mri([tissueMasksPath '\brainstem.nii']);
bWM = ft_read_mri([tissueMasksPath '\bWM.nii']);
cGM = ft_read_mri([tissueMasksPath '\cGM.nii']);
compacta = ft_read_mri([tissueMasksPath '\compacta.nii']);
CSF = ft_read_mri([tissueMasksPath '\CSF.nii']);
cWM = ft_read_mri([tissueMasksPath '\cWM.nii']);
eyes = ft_read_mri([tissueMasksPath '\eyes.nii']);
fat = ft_read_mri([tissueMasksPath '\fat.nii']);
muscle = ft_read_mri([tissueMasksPath '\muscle.nii']);
skin = ft_read_mri([tissueMasksPath '\skin.nii']);
spongiosa = ft_read_mri([tissueMasksPath '\spongiosa.nii']);

%% Plot tissue masks
cfg = [];
cfg.funparameter = 'anatomy';
cfg.funcolormap = spring;
cfg.location = 'center';

ft_sourceplot(cfg, bGM);
print([masksPath '\bGM'],'-dpng','-r300')
ft_sourceplot(cfg, brainstem);
print([masksPath '\brainstem'],'-dpng','-r300')
ft_sourceplot(cfg, bWM);
print([masksPath '\bWM'],'-dpng','-r300')
ft_sourceplot(cfg, cGM);
print([masksPath '\cGM'],'-dpng','-r300')
ft_sourceplot(cfg, compacta);
print([masksPath '\compacta'],'-dpng','-r300')
ft_sourceplot(cfg, CSF);
print([masksPath '\CSF'],'-dpng','-r300')
ft_sourceplot(cfg, cWM);
print([masksPath '\cWM'],'-dpng','-r300')
ft_sourceplot(cfg, eyes);
print([masksPath '\eyes'],'-dpng','-r300')
ft_sourceplot(cfg, fat);
print([masksPath '\fat'],'-dpng','-r300')
ft_sourceplot(cfg, muscle);
print([masksPath '\muscle'],'-dpng','-r300')
ft_sourceplot(cfg, skin);
print([masksPath '\skin'],'-dpng','-r300')
ft_sourceplot(cfg, spongiosa);
print([masksPath '\spongiosa'],'-dpng','-r300')
end
