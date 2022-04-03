%% Init FieldTrip
addpath([matlabroot '\toolbox\fieldtrip'])
ft_defaults

%% Define TPM path
TPM6 = 'eTPM6.nii';
TPM12 = 'eTPM12.nii';

mrtimPath = 'C:\Program Files\MATLAB\R2021a\toolbox\spm12\toolbox\MRTIM';
tissuesPath = [mrtimPath '\external\NET\template\tissues_MNI'];
tpmPath = [tissuesPath '\' TPM12]; % choose TPM6 or TPM12

%% Load TPM
tmp = ft_read_mri(tpmPath);

%% Extract a tissue [tissueNumber]
tissueNumber = 1; % choose from 1-6 or 1-12

tissue = tmp;
tissue.dim = tissue.dim(1:3);
tissue.anatomy = tissue.anatomy(:,:,:,tissueNumber);

%% Plot tissue
cfg = struct;
cfg.funparameter = 'anatomy'; %  not necessary
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, tissue);
set(fig, 'Name', 'TPM')

%% Save figure
imgPath = ''; % add folder to save to
fileName = ''; % add desired file name
print([imgPath '\' fileName],'-dpng','-r300')
