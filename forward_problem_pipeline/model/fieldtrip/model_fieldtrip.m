function [] = model_fieldtrip(Config)
% MODEL_FIELDTRIP takes segmented MRI, creates a mesh, headmodel and
% sourcemodel, aligns and projects electrode template to the mesh surface
% and computes the leadfield.
%
% Required:
%   Config.mriSegmented
%   Config.mriSegmented.path
%   Config.mriSegmented.method
%   Config.mriSegmented.nLayers
%   Config.output
%
% Optional:
%   Config.mriSegmented.norm2ind
%   Config.suffix
%   Config.visualize

%% Init
addpath_source;
const_path % inits 'Path' struct

%% Check Config
Info = struct;

% load template to test the path
elecTemplatePath = Path.data.elec.HydroCel;
[~] = ft_read_sens(elecTemplatePath);

check_required_field(Config, 'mriSegmented');
% TODO add previous submodule option
check_required_field(Config.mriSegmented, 'path');
check_required_field(Config.mriSegmented, 'method');
Config.mriSegmented.method = convertStringsToChars(Config.mriSegmented.method);
check_required_field(Config.mriSegmented, 'nLayers');

alignElectrodes = isfield(Config.mriSegmented, 'norm2ind');
Info.electrodes.align.bool = alignElectrodes;
if alignElectrodes
    norm2ind = load_var_from_mat('norm2ind', Config.mriSegmented.norm2ind);
else
    warning("[Config.mriSegmented.norm2ind] missing. Assuming segmented MRI is in norm space.")
end

check_required_field(Config, 'output');
suffix = '';
if isfield(Config, 'suffix')
    Config.suffix = convertStringsToChars(Config.suffix);
    suffix = ['_' Config.suffix];
end
methodName = Config.mriSegmented.method;
nLayersName = num2str(Config.mriSegmented.nLayers);
outputPath = [Config.output '\' methodName nLayersName suffix];
[outputPath, imgPath] = create_output_folder(outputPath);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end
save([outputPath '\config'], 'Config');

%% Load segmented MRI
% TODO add support for var instead of path
% TODO add support for .nii mrtim file without added masks
%mriSegmented = ft_read_mri(Config.mriSegmented.path);
mriSegmented = load_var_from_mat('mriSegmented', Config.mriSegmented.path);

tissueCfg = struct;
tissueCfg.method = Config.mriSegmented.method;
tissueCfg.nLayers = Config.mriSegmented.nLayers;
mriSegmented = ensure_tissue_and_masks(tissueCfg, mriSegmented);

%% Create mesh
mriSegmentedMaskless = remove_tissue_masks(tissueCfg, mriSegmented);
% 'ft_prepare_mesh' cannot determine the field that represents
% the segmentation with tissue masks present

cfg            = struct;
cfg.shift      = 0.3;
cfg.method     = 'hexahedral';
cfg.downsample = 2; % TODO test no downsample
% cfg.resolution = 1; % in mm, tutorial
% TODO is cfg.resolution forbidden % ? maybe n of elements
Info.mesh.ft_prepare_mesh.cfg = cfg;
mesh = ft_prepare_mesh(cfg, mriSegmentedMaskless);
save([outputPath '\mesh'], 'mesh');

%% visualize
fig = figure('Name', 'Mesh');
ft_plot_mesh(mesh, 'surfaceonly','yes', 'facecolor','skin', 'edgealpha',0.1)
view(135,30)
print([imgPath '\mesh'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Electrodes
%% 1 Read electrode-position template (in norm space)
% GSN-HydroCel-257.sfp at https://www.fieldtriptoolbox.org/template/electrode/
% 1st, 2nd, 3rd are points for allignment
% 257th is reference electrode

% TODO ? add: 'senstype', 'eeg'
Info.electrodes.template.path = elecTemplatePath;
elecTemplate = ft_read_sens(elecTemplatePath);
elecTemplate = ft_convert_units(elecTemplate, 'mm');

%% visualize
fig = figure;
ft_plot_sens(elecTemplate)
set(fig, 'Name', 'Electrodes - template')
print([imgPath '\elec_template'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% 2 Align electrodes to individual space
if alignElectrodes
    % (i) get fiducial points from FT elec template (is in norm space)
    Info.electrodes.realign.fid.template = "ft_read_sens('standard_1005.elc')";
    elecNorm = ft_read_sens('standard_1005.elc');
    Nas = elecNorm.chanpos(3,:);
    Rpa = elecNorm.chanpos(2,:);
    Lpa = elecNorm.chanpos(1,:);
    clear elec_norm

    Info.electrodes.realign.fid.norm2ind = norm2ind;
    % (iia) Allign fiducial points to ind space (with ft_warp_apply)
    Info.electrodes.realign.fid.alignMethod = 'ft_warp_apply';
    fid_aligned = ft_warp_apply(norm2ind, [Nas; Lpa; Rpa], 'homogeneous');

    % (iib) Allign fiducial points to ind space (with ft_transform_geometry)
    %info.electrodes.realign.fid.alignMethod = 'ft_transform_geometry';
    %fid_aligned = ft_transform_geometry(Config.norm2ind, [Nas; Lpa; Rpa]);

    % (iii) Allign elec template to ind space
    cfg = struct;
    cfg.method = 'fiducial';
    cfg.template.elecpos(1,:) = fid_aligned(1,:); % location of nas
    cfg.template.elecpos(2,:) = fid_aligned(2,:); % location of lpa
    cfg.template.elecpos(3,:) = fid_aligned(3,:); % location of rpa
    cfg.template.label = {'FidNz', 'FidT9', 'FidT10'};
    cfg.template.unit = 'mm';
    cfg.fiducial = {'FidNz','FidT9','FidT10'};
    Info.electrodes.realign.ft_electroderealign.cfg = cfg;
    elecTemplate = ft_electroderealign(cfg, elecTemplate);
    
    % (iv) Remove fiducial points
    elecTemplate = remove_fids(elecTemplate);

    %% visualize
    fig = figure;
    ft_plot_sens(elecTemplate)
    set(fig, 'Name', 'Electrodes - aligned to individual space')
    print([imgPath '\elec_aligned'],'-dpng','-r300')
    if ~visualize
        close(fig)
    end
end

%% 3 Project electrodes to head surface
cfg = struct;
cfg.method = 'project';
cfg.headshape = mesh;
elec = ft_electroderealign(cfg, elecTemplate);
cfg = rm_field_data(cfg, "headshape", "mesh");
Info.electrodes.project.ft_electroderealign.cfg = cfg;
save([outputPath '\elec'], 'elec');

%% visualize
fig = figure;
ft_plot_sens(elec)
set(fig, 'Name', 'Electrodes - projected to head surface')
print([imgPath '\elec_projected'],'-dpng')
if ~visualize
    close(fig)
end
%%
fig = plot_electrodes_aligned(mesh, elec, elecTemplate);
print([imgPath '\elec_projection'],'-dpng')
if ~visualize
    close(fig)
end

%% Create head model
cfg = struct;

% (a) Simbio % see doc ft_headmodel_simbio
cfg.method = 'simbio';

% (b) DUNEuro % see doc ft_headmodel_duneuro
% ! not tested, works only on Linux machines
%cfg.method = 'duneuro';
%cfg.duneuro_settings = ; % optional (see http://www.duneuro.org)

[cfg.conductivity, cfg.tissuelabel] = get_conductivity(Config.mriSegmented.method, Config.mriSegmented.nLayers);
Info.headmodel.ft_prepare_headmodel.cfg = cfg;
headmodel = ft_prepare_headmodel(cfg, mesh);
headmodel = ft_convert_units(headmodel, 'mm');
save([outputPath '\headmodel'], 'headmodel');

%% visualize
fig = figure();
ft_plot_mesh(headmodel) % TODO consider 'ft_plot_headmodel'
ft_plot_sens(elec,'facecolor','b','elecsize',20);
view(135,30)
print([imgPath '\electrodes_projected'],'-dpng')
if ~visualize
    clos(fig)
end

%% Create sourcemodel
if Config.mriSegmented.method == "mrtim"
    mriSegmented.gray = mriSegmented.bgm | mriSegmented.cgm;
end

cfg = struct;
%cfg.method = 'basedonmri' % is determined automatically from specified cfg options
cfg.resolution = .6; % Shaine has 6 mm % tutorial: 7.5
% TODO doc says 'cfg.resolution' is in 'mm', this works as intended though
cfg.mri = mriSegmented;
cfg.smooth = 0; % tutorial: 5
%cfg.threshold = 0.1; % is default
%cfg.inwardshift = 1; % tutorial, shifts dipoles away from surfaces

%cfg.elec = elec;
%cfg.headmodel = headmodel; TODO ?

sourcemodel = ft_prepare_sourcemodel(cfg);
sourcemodel = ft_convert_units(sourcemodel,'mm');
cfg = rm_field_data(cfg, "mri", "mriSegmented");
Info.sourcemodel.ft_prepare_sourcemodel.cfg = cfg;
Info.sourcemodel.n_sources = sum(sourcemodel.inside);
save([outputPath '\sourcemodel'], 'sourcemodel');

if Config.mriSegmented.method == "mrtim"
    mriSegmented = rmfield(mriSegmented, "gray");
end

%% visualize
% TODO ? better visualization
cfg = struct;
cfg.method = 'hexahedral';

% TODO un-hardcode this:
if Config.mriSegmented.method == "fieldtrip"
    cfg.tissue = {'gray'};
elseif Config.mriSegmented.method == "mrtim"
    cfg.tissue = {'bgm', 'cgm'};
else
    warning("Unrecognized segmentation method in sourcemodel viualization. Defaulting to label 'gray' for gray matter in segmented mri.")
end

cfg.numvertices = 5000;
gray_mesh = ft_prepare_mesh(cfg, mriSegmented);
gray_mesh = ft_convert_units(gray_mesh,'mm');

fig = figure();
title(['nSources = ' num2str(Info.sourcemodel.n_sources)])
ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:));
ft_plot_mesh(gray_mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3);
view(115,15)
print([imgPath '\sources'],'-dpng')

if ~visualize
    close(fig)
end
clear gray_mash;

%% Leadfield
%% 1 Compute transfer matrix
Info.leadfield.ft_prepare_vol_sens = true;
[headmodel, elec] = ft_prepare_vol_sens(headmodel, elec);
save([outputPath '\headmodel'], 'headmodel');
save([outputPath '\elec'], 'elec');

%% 2 Compute leadfield
cfg = struct;
%cfg.grid = sourcemodel;
cfg.sourcemodel = sourcemodel;
cfg.headmodel = headmodel;
cfg.elec = elec;
% cfg.reducerank = 3; % tutorial
sourcemodel = ft_prepare_leadfield(cfg);
cfg = rm_field_data(cfg, "sourcemodel");
cfg = rm_field_data(cfg, "headmodel");
cfg = rm_field_data(cfg, "elec");
Info.leadfield.ft_prepare_leadfield.cfg = cfg;
save([outputPath '\sourcemodel'], 'sourcemodel');

%% Save info
save([outputPath '\info'], 'Info');
end
