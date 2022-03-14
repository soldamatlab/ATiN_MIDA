function [] = model_fieldtrip(Config)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd));
addpath([wd '\..\..\common']);

%% Innit FieldTrip
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip)
ft_defaults

%% Config
info = struct;

% load template to test the path
elecTemplatePath = [wd '\..\data\elec_template\GSN-HydroCel-257.sfp'];
[~] = ft_read_sens(elecTemplatePath);

check_required_field(Config, 'mriSegmented');
% TODO add previous submodule option
check_required_field(Config.mriSegmented, 'path');
check_required_field(Config.mriSegmented, 'method');
check_required_field(Config.mriSegmented, 'nLayers');

alignElectrodes = isfield(Config.mriSegmented, 'norm2ind');
info.electrodes.align.bool = alignElectrodes;
if alignElectrodes
    norm2ind = load_var_from_mat('norm2ind', Config.mriSegmented.norm2ind);
else
    warning("[Config.mriSegmented.norm2ind] missing. Assuming segmented MRI is in norm space.")
end

check_required_field(Config.path, 'output');
[outputPath, imgPath] = create_output_folder(Config.path.output);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load segmented MRI
% TODO add support for var instead of path
% TODO add support for .nii mrtim file without added masks
%mriSegmented = ft_read_mri(Config.mriSegmented.path);
mriSegmented = load_var_from_mat('mriSegmented', Config.mriSegmented.path);

%% Create mesh
cfg            = struct;
cfg.shift      = 0.3;
cfg.method     = 'hexahedral';
cfg.downsample = 2; % TODO test no downsample
% cfg.resolution = 1; % in mm, tutorial
% TODO is cfg.resolution forbidden % ? maybe n of elements
info.ft_prepare_mesh.cfg = cfg;
mesh = ft_prepare_mesh(cfg, mriSegmented);

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
info.electrodes.template.path = elecTemplatePath;
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
    info.electrodes.realign.fid.template = "ft_read_sens('standard_1005.elc')";
    elecNorm = ft_read_sens('standard_1005.elc');
    Nas = elecNorm.chanpos(3,:);
    Rpa = elecNorm.chanpos(2,:);
    Lpa = elecNorm.chanpos(1,:);
    clear elec_norm

    info.electrodes.realign.fid.norm2ind = norm2ind;
    % (iia) Allign fiducial points to ind space (with ft_warp_apply)
    info.electrodes.realign.fid.alignMethod = 'ft_warp_apply';
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
    info.electrodes.realign.ft_electroderealign.cfg = cfg;
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
info.electrodes.project.ft_electroderealign.cfg = cfg;
elecProjected = ft_electroderealign(cfg, elecTemplate);

%% visualize
fig = figure;
ft_plot_sens(elecProjected)
set(fig, 'Name', 'Electrodes - projected to head surface')
print([imgPath '\elec_projected'],'-dpng')
if ~visualize
    close(fig)
end
%%
fig = plot_electrodes_aligned(mesh, elecProjected, elecTemplate);
print([imgPath '\elec_projection'],'-dpng')
if ~visualize
    close(fig)
end

%% Create head model
cfg = struct;

% (a) Simbio % see doc ft_headmodel_simbio
cfg.method = 'simbio';

% (b) DUNEuro % see doc ft_headmodel_duneuro
% ! works only on Linux machines
%cfg.method = 'duneuro';
%cfg.duneuro_settings = ; % optional (see http://www.duneuro.org)

[cfg.conductivity, cfg.tissuelabel] = get_conductivity(Config.mriSegmented.method, Config.mriSegmented.nLayers);
info.headmodel.ft_prepare_headmodel.cfg = cfg;
headmodel = ft_prepare_headmodel(cfg, mesh);
headmodel = ft_convert_units(headmodel, 'mm');

%% visualize
fig = figure();
ft_plot_mesh(headmodel) % TODO consider 'ft_plot_headmodel'
ft_plot_sens(elecProjected,'facecolor','b','elecsize',20);
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

info.sourcemodel.ft_prepare_sourcemodel.cfg = cfg;
sourcemodel = ft_prepare_sourcemodel(cfg);
sourcemodel = ft_convert_units(sourcemodel,'mm');
info.sourcemodel.n_sources = sum(sourcemodel.inside);

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
title(['nSources = ' num2str(info.sourcemodel.n_sources)])
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
info.leadfield.ft_prepare_vol_sens = true;
[headmodel, elecProjected] = ft_prepare_vol_sens(headmodel, elecProjected);

%% 2 Compute leadfield
cfg = struct;
cfg.grid = sourcemodel;
%cfg.sourcemodel = sourcemodel;
cfg.headmodel = headmodel;
cfg.elec = elecTemplate;
% cfg.reducerank = 3; % tutorial
info.leadfield.ft_prepare_leadfield.cfg = cfg;
sourcemodel = ft_prepare_leadfield(cfg);

%% Save data
save([outputPath '\elec'],'elecProjected');
save([outputPath '\mesh'],'mesh');
save([outputPath '\headmodel'],'headmodel');
save([outputPath '\sourcemodel'],'sourcemodel');

save([outputPath '\config'],'Config');
save([outputPath '\info'],'info');
end
