function [] = forward_problem_FT(Config)
%% Innit FieldTrip
restoredefaultpath
addpath(Config.FT_path)
ft_defaults

%% Import commons
addpath('../common');

%% Check Config
if ~check_required_field(Config, 'FT_path')
    return
end
if ~check_required_field(Config, 'mri_path')
    return
end
if ~check_required_field(Config, 'elec_template_path')
    return
end
[~] = ft_read_sens(Config.elec_template_path); % load template to test the path
if ~(check_required_field(Config, 'out_path') && check_required_field(Config, 'data_name'))
    return
end

%% Setup
if isfield(Config, 'run_name')
    run_name = Config.run_name;
else
    run_name = sprintf('run_%s', datestr(now, 'yyyy-mm-dd-HHMM'));
end

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

output_path = [Config.out_path '/' Config.data_name '/' run_name];
if exist(output_path, 'dir')
    fprintf("Output folder with given / generated name already exists!\n")
    return
end
if ~mkdir(output_path)
    fprintf("Could not create output folder!\n")
    return
end
img_path = [output_path '\img'];
if ~mkdir(img_path)
    fprintf("Could not create image output folder!\n")
    return
end

info = struct;

%% 1 Read the MRI
mri = ft_read_mri(Config.mri_path);

%% visualize
cfg = struct;
%cfg.funparameter = 'anatomy';
%cfg.colormap = spring;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mri);
set(fig, 'Name', 'MRI original')
print([img_path '\mri_original'],'-dpng','-r300')
if ~visualize
    close fig
end

%% (5) Realign the MRI
% ! electrodes are realigned to individual space instead
% cfg = struct;
% cfg.method = 'interactive';
% cfg.coordsys = 'acpc';
% mri = ft_volumerealign(cfg, mri);

%% visualize
% if visualize
%     cfg = struct;
%     cfg.location = 'center';
%     figure()
%     ft_sourceplot(cfg, mri);
% end

%% 2 Reslice the MRI
cfg = struct;
cfg.method = 'linear';
cfg.dim    = [256 350 350];
mri = ft_volumereslice(cfg, mri);
mri = ft_convert_units(mri,'mm');

%% visualize
cfg = struct;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mri);
set(fig, 'Name', 'MRI resliced')
print([img_path '\mri_resliced'],'-dpng','-r300')
if ~visualize
    close fig
end

%% FEM
%% 3(FEM) Segment the MRI
mri.coordsys = 'acpc';
cfg = struct;
cfg.output         = {'scalp','skull','csf','gray','white'};
% cfg.brainsmooth    = 1; % from the tutorial
% cfg.scalpthreshold = 0.11;
% cfg.skullthreshold = 0.15;
% cfg.brainthreshold = 0.15;

% ! assumes 'mm', seems to work with mri in 'cm' too
mri_segmented = ft_volumesegment(cfg, mri);

%% visualize
seg_i = ft_datatype_segmentation(mri_segmented, 'segmentationstyle', 'indexed');

cfg              = struct;
cfg.funparameter = 'tissue';
cfg.funcolormap  = lines(6); % distinct color per tissue
cfg.location     = 'center';
% cfg.atlas        = seg_i;    % the segmentation can also be used as atlas
fig = figure;
ft_sourceplot(cfg, seg_i, mri);
set(fig, 'Name', 'MRI segmented')
print([img_path '\mri_segmented'],'-dpng','-r300')
if ~visualize
    close fig
end

%% 4(FEM) Create the mash
cfg        = struct;
cfg.shift  = 0.3;
cfg.method = 'hexahedral';
cfg.downsample = 2; % TODO test no downsample
% cfg.resolution = 1; % in mm, tutorial % TODO is forbidden % ? mozna pocet elementu
mesh = ft_prepare_mesh(cfg, mri_segmented);

%% visualize
fig = figure('Name', 'Mesh');
ft_plot_mesh(mesh, 'surfaceonly','yes', 'facecolor','skin', 'edgealpha',0.1)
view(135,30)
print([img_path '\mesh'],'-dpng','-r300')
if ~visualize
    close fig
end

%% 5(FEM) Electrodes
%% 5a Read electrode-position template
% GSN-HydroCel-257.sfp at https://www.fieldtriptoolbox.org/template/electrode/
% 1st, 2nd, 3rd are points for allignment
% 257th is reference electrode
elec_template = ft_read_sens(Config.elec_template_path); % ? add: 'senstype', 'eeg'
elec_template = ft_convert_units(elec_template, 'mm');

% fid positions from FT (FT elec template is in norm space)
elec_norm = ft_read_sens('standard_1005.elc');
Nas = elec_norm.chanpos(3,:);
Rpa = elec_norm.chanpos(2,:);
Lpa = elec_norm.chanpos(1,:);
clear elec_norm

%% visualize
if visualize
    fig = figure;
    ft_plot_sens(elec_template)
    set(fig, 'Name', 'Electrodes - template')
end

%% 5b Find transformation matrix to individual space
cfg = struct;
mri.coordsys = 'acpc';
cfg.nonlinear = 'no';
cfg.spmversion = 'spm12';
mri_normalised = ft_volumenormalise(cfg, mri);

%%
%transMat = mri_normalised.cfg.spmparams.Affine;
transMat = mri_normalised.cfg.initial;

%% visualize
cfg = struct;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mri_normalised);
set(fig, 'Name', 'MRI normalised')
print([img_path '\mri_normalised'],'-dpng','-r300')
if ~visualize
    close fig
end
clear mri_normalised

%% 5c Align electrodes to individual space (ft_warp_apply)
fid_aligned = ft_warp_apply(transMat^-1, [Nas; Lpa; Rpa], 'homogeneous');
info.electrodes.align = 'ft_warp_apply';

%% 5c Align electrodes to individual space (ft_transform_geometry)
%fid_aligned = ft_transform_geometry(transMat, [Nas; Lpa; Rpa]);
%info.electrodes.align = 'ft_transform_geometry';

%%
cfg = struct;
cfg.method = 'fiducial';
cfg.template.elecpos(1,:) = fid_aligned(1,:); % location of nas
cfg.template.elecpos(2,:) = fid_aligned(2,:); % location of lpa
cfg.template.elecpos(3,:) = fid_aligned(3,:); % location of rpa
cfg.template.label = {'FidNz', 'FidT9', 'FidT10'};
cfg.template.unit = 'mm';
cfg.fiducial = {'FidNz','FidT9','FidT10'};
elec_aligned = ft_electroderealign(cfg, elec_template);

clear elec_template

%% visualize
if visualize
    fig = figure;
    ft_plot_sens(elec_aligned)
    set(fig, 'Name', 'Electrodes - aligned to individual space')
end

%% 5d Project electrodes to the head surface
cfg = struct;
cfg.method = 'project';
cfg.headshape = mesh;
elec = ft_electroderealign(cfg, elec_aligned);

% Remove fiducial points
elec.chantype = elec.chantype(4:end);
elec.chanunit = elec.chanunit(4:end);
elec.elecpos = elec.elecpos(4:end,:);
elec.label = elec.label(4:end);
elec.chanpos = elec.chanpos(4:end,:);
elec.cfg.channel = elec.cfg.channel(4:end);
elec.tra = elec.tra(4:end,4:end);

%% visualize
if visualize
    fig = figure;
    ft_plot_sens(elec)
    set(fig, 'Name', 'Electrodes - projected to head surface')
end
fig = plot_electrodes_aligned(mesh, elec, elec_aligned);
print([img_path '\electrode_template'],'-dpng')
if ~visualize
    close fig
end

%% 6(FEM) Create head model
cfg = struct;
cfg.method = 'simbio';
% cfg.conductivity = [0.43 0.0024 1.79 0.14 0.33]; % tutorial, same as tissuelabel in vol_simbio
cfg.conductivity = [1.79 0.33 0.43 0.01 0.14];
cfg.tissuelabel = {'csf', 'gray', 'scalp', 'skull', 'white'};
headmodel = ft_prepare_headmodel(cfg, mesh);
headmodel = ft_convert_units(headmodel, 'mm');

%% visualize
fig = figure();
ft_plot_mesh(headmodel)
ft_plot_sens(elec,'facecolor','b','elecsize',20);
view(135,30)
print([img_path '\electrodes_projected'],'-dpng')
if ~visualize
    close fig
end

%% 7(FEM) Create the sourcemodel
cfg = struct;
%cfg.method = 'basedonmri' % determined automatically from specified cfg options
cfg.resolution = .6; % Shaine has 6 mm % tutorial: 7.5
% TODO doc says 'cfg.resolution' is in 'mm', this works as intended though
cfg.mri = mri_segmented;
cfg.smooth = 0; % tutorial: 5
%cfg.threshold = 0.1; % is default
%cfg.inwardshift = 1; % tutorial, shifts dipoles away from surfaces

sourcemodel = ft_prepare_sourcemodel(cfg);
sourcemodel = ft_convert_units(sourcemodel,'mm');
info.sourcemodel.n_sources = sum(sourcemodel.inside);

%% visualize
% TODO ? better visualization
cfg = struct;
cfg.method = 'hexahedral';
cfg.tissue      = {'gray'};
cfg.numvertices = 5000;
gray_mesh = ft_prepare_mesh(cfg,mri_segmented);
gray_mesh = ft_convert_units(gray_mesh,'mm');

fig = figure();
title(['nSources = ' num2str(info.sourcemodel.n_sources)])
ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:));
ft_plot_mesh(gray_mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3);
view(115,15)
print([img_path '\sources'],'-dpng')

if ~visualize
    close fig
end
clear grey_mash;

%% 8(FEM) Compute the leadfield
%% 8a compute transfer matrix
[headmodel, elec] = ft_prepare_vol_sens(headmodel, elec);

%% 8b compute leadfield
cfg = struct;
cfg.sourcemodel = sourcemodel;
cfg.headmodel = headmodel;
cfg.elec = elec;
% cfg.reducerank = 3; % tutorial
leadfield = ft_prepare_leadfield(cfg);

%% Save data
save([output_path '\elec'],'elec');
save([output_path '\mesh'],'mesh');
save([output_path '\headmodel'],'headmodel');
save([output_path '\sourcemodel'],'sourcemodel');
save([output_path '\leadfield'],'leadfield');
save([output_path '\mri'],'mri');
save([output_path '\mri_segmented'],'mri_segmented');
save([output_path '\transMat'],'transMat');
save([output_path '\info'],'info');
end
