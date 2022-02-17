%% Innit FieldTrip
restoredefaultpath
addpath([matlabroot '\toolbox\fieldtrip'])
ft_defaults

%% Load paths
outPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\mrtim';
dataName = 'ANDROVICOVA_RENATA';
runName = '01';
path = [outPath '\' dataName '\' runName];

tissue_masks_path = [path '\tissue_masks'];
img_path = [path '\img'];
masks_path = [img_path '\tissue_masks'];

%% Load data
mri = ft_read_mri([path '\anatomy_prepro.nii']);
mri_segmented = ft_read_mri([path '\anatomy_prepro_segment.nii']);

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

%% Prepare seg
bGM = ft_read_mri([tissue_masks_path '\bGM.nii']);
brainstem = ft_read_mri([tissue_masks_path '\brainstem.nii']);
bWM = ft_read_mri([tissue_masks_path '\bWM.nii']);
cGM = ft_read_mri([tissue_masks_path '\cGM.nii']);
compacta = ft_read_mri([tissue_masks_path '\compacta.nii']);
CSF = ft_read_mri([tissue_masks_path '\CSF.nii']);
cWM = ft_read_mri([tissue_masks_path '\cWM.nii']);
eyes = ft_read_mri([tissue_masks_path '\eyes.nii']);
fat = ft_read_mri([tissue_masks_path '\fat.nii']);
muscle = ft_read_mri([tissue_masks_path '\muscle.nii']);
skin = ft_read_mri([tissue_masks_path '\skin.nii']);
spongiosa = ft_read_mri([tissue_masks_path '\spongiosa.nii']);

%% Plot
cfg = [];
cfg.funparameter = 'anatomy';
cfg.funcolormap = [lines(6); prism(6); cool(1)];
cfg.location = 'center';
ft_sourceplot(cfg, seg_i);
%% Save
print([img_path '\mri_segmented'],'-dpng','-r300')

%% Plot
cfg = [];
cfg.funparameter = 'tissue';
cfg.funcolormap = [lines(6); prism(6); cool(1)];
cfg.location = 'center';
ft_sourceplot(cfg, seg_i, mri);
%% Save
print([img_path '\mri_segmented_anatomy'],'-dpng','-r300')

%% Plot tissue masks
cfg = [];
cfg.funparameter = 'anatomy';
cfg.funcolormap = spring;
cfg.location = 'center';

ft_sourceplot(cfg, bGM);
print([masks_path '\bGM'],'-dpng','-r300')
ft_sourceplot(cfg, brainstem);
print([masks_path '\brainstem'],'-dpng','-r300')
ft_sourceplot(cfg, bWM);
print([masks_path '\bWM'],'-dpng','-r300')
ft_sourceplot(cfg, cGM);
print([masks_path '\cGM'],'-dpng','-r300')
ft_sourceplot(cfg, compacta);
print([masks_path '\compacta'],'-dpng','-r300')
ft_sourceplot(cfg, CSF);
print([masks_path '\CSF'],'-dpng','-r300')
ft_sourceplot(cfg, cWM);
print([masks_path '\cWM'],'-dpng','-r300')
ft_sourceplot(cfg, eyes);
print([masks_path '\eyes'],'-dpng','-r300')
ft_sourceplot(cfg, fat);
print([masks_path '\fat'],'-dpng','-r300')
ft_sourceplot(cfg, muscle);
print([masks_path '\muscle'],'-dpng','-r300')
ft_sourceplot(cfg, skin);
print([masks_path '\skin'],'-dpng','-r300')
ft_sourceplot(cfg, spongiosa);
print([masks_path '\spongiosa'],'-dpng','-r300')
