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
%   Config.mriSegmented.norm2ind = path(s) to '.mat' file(s) with 'norm2ind'        % TODO add support for var
%                                  var (4x4 double)
%   Config.sourcemodel = struct, has to have fields 'pos' and 'dim',
%                        ! 'pos' has to be in mm !
%                      or
%                      = 'matchpos' to ensure matching dipole positions
%   Config.suffix
%   Config.visualize

%% Init
addpath_source;
const_path % inits 'Path' struct

%% Load elec template to test the path
elecTemplatePath = Path.data.elec.HydroCel;
[~] = ft_read_sens(elecTemplatePath);

%% Segmented MRI config
check_required_field(Config, 'mriSegmented');
% TODO add previous submodule option
check_required_field(Config.mriSegmented, 'path');
Config.mriSegmented.pah = convertStringsToChars(Config.mriSegmented.path);
check_required_field(Config.mriSegmented, 'method');
Config.mriSegmented.method = convertStringsToChars(Config.mriSegmented.method);
check_required_field(Config.mriSegmented, 'nLayers');
if iscell(Config.mriSegmented.nLayers)
    Config.nLayers = cell2mat(Config.nLayers);
end
nPath = length(Config.mriSegmented.path);
nMethod = length(Config.mriSegmented.method);
nNLayers = length(Config.mriSegmented.nLayers);
if ~(nPath == nMethod && nMethod == nNLayers)
    error("Different numbers of mri [path]s, segmentation [method]s and [nLayers] specified in Config.mriSegmented.")
end

if isfield(Config.mriSegmented, 'norm2ind')
    Config.mriSegmented.norm2ind = convertStringToChars(Config.mriSegmented.norm2ind);
    if nPath ~= length(Config.mriSegmented.norm2ind)
        error("Config.mriSegmented.norm2ind length does not match number of segmented MRIs.")
    end
else
    Config.mriSegmented.norm2ind = cell(1, nPath);
end

Infos = cell(1, nPath);
Infos(:) = {struct};

%% Output path
check_required_field(Config, 'output');
suffix = cell(1, nPath);
suffix(:) = {''};
if isfield(Config, 'suffix')
    Config.suffix = convertStringsToChars(Config.suffix);
    if ~iscell(Config.suffix)
        Config.suffix = {Config.suffix};
    end
    nSuffix = length(Config.suffix);
    if nSuffix ~= nPath
        error("Config.suffix length does not match number of segmented MRIs.")
    end
    for s = 1:nSuffix
        if ~isempty(Config.suffix{s})
            suffix{s} = ['_' Config.suffix{s}];
        end
    end
end
segName = cell(1, nPath);
outputFieldName = cell(1, nPath);
outputPath = cell(1, nPath);
imgPath = cell(1, nPath);
for i = 1:nPath
    methodName = Config.mriSegmented.method{i};
    nLayersName = num2str(Config.mriSegmented.nLayers(i));
    segName{i} = [methodName nLayersName suffix{i}];
    outputFieldName{i} = ['output_' segName{i}];
    Config.(outputFieldName{i}) = [Config.output '\' segName{i}];
    [outputPath{i}, imgPath{i}] = create_output_folder(Config.(outputFieldName{i}));
end

%% Load norm2ind(s)
alignElectrodes = NaN(1, nPath);
for s = 1:nPath
    alignElectrodes(s) = ~isempty(Config.mriSegmented.norm2ind{s});
    Infos{s}.electrodes.align.bool = logical(alignElectrodes(s));
end
alignElectrodes = logical(alignElectrodes);
norm2ind = cell(1, nPath);
for n = 1:nPath
    if alignElectrodes(n)
        norm2ind{n} = load_var_from_mat('norm2ind', Config.mriSegmented.norm2ind{n});
    else
        warning("[Config.mriSegmented.norm2ind] missing. Assuming '%s' segmented MRI is in norm space.", segName{n})
    end
end

%% Sourcemodel config
matchpos = false;
if isfield(Config, 'sourcemodel')
    if strcmp(Config.sourcemodel, 'matchpos')
        matchpos = true;
    elseif isstruct(Config.sourcemodel)
        check_required_field(Config.sourcemodel, 'pos');
        check_required_field(Config.sourcemodel, 'dim');
    else
        error("Config.sourcemodel has to be 'matchpos' or struct with 'pos' (in mm) and 'dim' fields.")
    end
end

%% Miscellaneous config
if ~isfield(Config, 'visualize')
    Config.visualize = false;
end
visualize = Config.visualize;
multipath_save(outputPath, 'config', Config, 'Config');

%% Load segmented MRI
% TODO add support for var instead of path
mriSegmented = cell(1, nPath);
for s = 1:nPath
    mriSegmented{s} = load_mri_anytype(Config.mriSegmented.path{s},'mriSegmented');
    mriSegmented{s} = ft_convert_units(mriSegmented{s}, 'mm');
    
    tissueCfg = struct;
    tissueCfg.method = Config.mriSegmented.method{s};
    tissueCfg.nLayers = Config.mriSegmented.nLayers(s);
    mriSegmented{s} = ensure_tissue_and_masks(tissueCfg, mriSegmented{s});
end

%% Create mesh
cfg            = struct;
cfg.shift      = 0.3;
cfg.method     = 'hexahedral';
cfg.downsample = 2; % TODO test no downsample
% cfg.resolution = 1; % in mm, tutorial
% TODO is cfg.resolution forbidden % ? maybe n of elements
Infos = assign_all_struct_cells(Infos, 'mesh.ft_prepare_mesh.cfg', cfg);
meshes = cell(1, nPath);
for s = 1:nPath
    tissueCfg = struct;
    tissueCfg.method = Config.mriSegmented.method{s};
    tissueCfg.nLayers = Config.mriSegmented.nLayers(s);
    mriSegmentedMaskless = remove_tissue_masks(tissueCfg, mriSegmented{s});     % 'ft_prepare_mesh' cannot determine the field that represents
    mesh = ft_prepare_mesh(cfg, mriSegmentedMaskless);                          % the segmentation with tissue masks present
    clear mriSegmentedMaskless
    save([outputPath{s} '\mesh'], 'mesh');
    meshes{s} = mesh; clear mesh

    %% visualize
    fig = figure('Name', 'Mesh');
    ft_plot_mesh(meshes{s}, 'surfaceonly','yes', 'facecolor','skin', 'edgealpha',0.1)
    view(135,30)
    print([imgPath{s} '\mesh'],'-dpng','-r300')
    if ~visualize
        close(fig)
    end
end

%% Electrodes
%% 1 Read electrode-position template (in norm space)
% GSN-HydroCel-257.sfp at https://www.fieldtriptoolbox.org/template/electrode/
% 1st, 2nd, 3rd are points for allignment
% 257th is reference electrode

% TODO ? add: 'senstype', 'eeg'
Infos = assign_all_struct_cells(Infos, 'electrodes.template.path', elecTemplatePath);
elecTemplate = ft_read_sens(elecTemplatePath);
elecTemplate = ft_convert_units(elecTemplate, 'mm');
elecTemplates = cell(1, nPath);
elecTemplates(:) = {elecTemplate};
clear elecTemplate

%% visualize
fig = figure;
ft_plot_sens(elecTemplates{1})
set(fig, 'Name', 'Electrodes - template')
multipath_print(imgPath, 'elec_template');
if ~visualize
    close(fig)
end

%% 2 Align electrodes to individual space
if sum(alignElectrodes)
    % (i) get fiducial points from FT elec template (is in norm space)
    elecNorm = ft_read_sens('standard_1005.elc');
    Nas = elecNorm.chanpos(3,:);
    Rpa = elecNorm.chanpos(2,:);
    Lpa = elecNorm.chanpos(1,:);
    clear elec_norm
end

for s = 1:nPath
    if ~alignElectrodes(s)
        continue
    end

    Infos{s}.electrodes.realign.fid.template = "ft_read_sens('standard_1005.elc')";
    Infos{s}.electrodes.realign.fid.norm2ind = norm2ind{s};
    % (iia) Allign fiducial points to ind space (with ft_warp_apply)
    Infos{s}.electrodes.realign.fid.alignMethod = 'ft_warp_apply';
    fid_aligned = ft_warp_apply(norm2ind{s}, [Nas; Lpa; Rpa], 'homogeneous');

    % (iib) Allign fiducial points to ind space (with ft_transform_geometry)
    %info.electrodes.realign.fid.alignMethod = 'ft_transform_geometry';
    %fid_aligned = ft_transform_geometry(Config.mriSegmented.norm2ind, [Nas; Lpa; Rpa]);

    % (iii) Allign elec template to ind space
    cfg = struct;
    cfg.method = 'fiducial';
    cfg.template.elecpos(1,:) = fid_aligned(1,:); % location of nas
    cfg.template.elecpos(2,:) = fid_aligned(2,:); % location of lpa
    cfg.template.elecpos(3,:) = fid_aligned(3,:); % location of rpa
    cfg.template.label = {'FidNz', 'FidT9', 'FidT10'};
    cfg.template.unit = 'mm';
    cfg.fiducial = {'FidNz','FidT9','FidT10'};
    Infos{s}.electrodes.realign.ft_electroderealign.cfg = cfg;
    elecTemplates{s} = ft_electroderealign(cfg, elecTemplates{s});

    %% visualize
    fig = figure;
    ft_plot_sens(elecTemplates{s})
    set(fig, 'Name', 'Electrodes - aligned to individual space')
    print([imgPath '\elec_aligned'],'-dpng','-r300')
    if ~visualize
        close(fig)
    end
end

%% 3 Remove fiducial points
for s = 1:nPath
    elecTemplates{s} = remove_fids(elecTemplates{s});
end

%% 4 Project electrodes to head surface
elecs = cell(1, nPath);
for s = 1:nPath
    cfg = struct;
    cfg.method = 'project';
    cfg.headshape = meshes{s};
    elec = ft_electroderealign(cfg, elecTemplates{s});
    cfg = rm_field_data(cfg, "headshape", "mesh");
    Infos{s}.electrodes.project.ft_electroderealign.cfg = cfg;
    save([outputPath{s} '\elec'], 'elec');
    elecs{s} = elec; clear elec

    %% visualize
    fig = figure;
    ft_plot_sens(elecs{s})
    set(fig, 'Name', 'Electrodes - projected to head surface')
    print([imgPath{s} '\elec_projected'],'-dpng')
    if ~visualize
        close(fig)
    end
    %%
    fig = plot_electrodes_aligned(meshes{s}, elecs{s}, elecTemplates{s});
    print([imgPath{s} '\elec_projection'],'-dpng')
    if ~visualize
        close(fig)
    end
end

%% Create head model
headmodels = cell(1, nPath);
for s = 1:nPath
    cfg = struct;
    % (a) Simbio % see doc ft_headmodel_simbio
    cfg.method = 'simbio';
    
    % (b) DUNEuro % see doc ft_headmodel_duneuro
    % ! not tested, works only on Linux machines
    %cfg.method = 'duneuro';
    %cfg.duneuro_settings = ; % optional (see http://www.duneuro.org)
    
    [cfg.conductivity, cfg.tissuelabel] = get_conductivity(Config.mriSegmented.method{s}, Config.mriSegmented.nLayers(s));
    Infos{s}.headmodel.ft_prepare_headmodel.cfg = cfg;
    headmodel = ft_prepare_headmodel(cfg, meshes{s});
    headmodel = ft_convert_units(headmodel, 'mm');
    save([outputPath{s} '\headmodel'], 'headmodel');
    headmodels{s} = headmodel; clear headmodel
    
    %% visualize
    fig = figure();
    ft_plot_mesh(headmodels{s}) % TODO consider 'ft_plot_headmodel'
    ft_plot_sens(elecs{s},'facecolor','b','elecsize',20);
    view(135,30)
    print([imgPath{s} '\electrodes_projected'],'-dpng')
    if ~visualize
        close(fig)
    end
end

%% Create sourcemodel
if matchpos
    [pos, dim] = prepare_sourcepos(mriSegmented);
end
sourcemodels = cell(1, nPath);
for s = 1:nPath
    if strcmp(Config.mriSegmented.method{s}, 'mrtim')
        mriBackup = mriSegmented{s};
        mriSegmented{s}.gray = mriSegmented{s}.bgm | mriSegmented{s}.cgm;
        mriSegmented{s} = rmfield(mriSegmented{s}, 'bgm');
        mriSegmented{s} = rmfield(mriSegmented{s}, 'cgm');
    end

    if isfield(Config, 'sourcemodel')
        cfg = struct;
        cfg.method = 'basedonpos';
        if matchpos
            cfg.sourcemodel.pos = pos;
            cfg.sourcemodel.dim = dim;
            cfg.sourcemodel.inside = get_inside(mriSegmented{s}, pos, 'mm');
        else
            cfg.sourcemodel.pos = Config.sourcemodel.pos;
            cfg.sourcemodel.dim = Config.sourcemodel.dim;
            cfg.sourcemodel.inside = get_inside(mriSegmented{s}, Config.sourcemodel.pos, 'mm'); % TODO support other units
        end
        sourcemodel = ft_prepare_sourcemodel(cfg);
        cfg.sourcemodel = rm_field_data(cfg.sourcemodel, "pos", "Config.sourcemodel.pos");
        cfg.sourcemodel = rm_field_data(cfg.sourcemodel, "dim", "Config.sourcemodel.dim");
        cfg.sourcemodel = rm_field_data(cfg.sourcemodel, "inside", "get_inside(mriSegmented, Config.sourcemodel.pos)");
    else    
        cfg = struct;
        cfg.method = 'basedonmri';
        cfg.unit = 'mm';
        cfg.resolution = 6; % Shaine has 6 mm % tutorial: 7.5
        % ! resolution depends on both MRI and cfg units !
        cfg.mri = mriSegmented{s};
        cfg.smooth = 'no'; % tutorial: 5
        %cfg.threshold = 0.1; % is default
        %cfg.inwardshift = 1; % tutorial, shifts dipoles away from surfaces
        sourcemodel = ft_prepare_sourcemodel(cfg);
        cfg = rm_field_data(cfg, "mri", "mriSegmented");
    end
    Infos{s}.sourcemodel.ft_prepare_sourcemodel.cfg = cfg;
    Infos{s}.sourcemodel.n_sources = sum(sourcemodel.inside);
    save([outputPath{s} '\sourcemodel'], 'sourcemodel');
    sourcemodels{s} = sourcemodel; clear sourcemodel
    
    %% visualize
    % TODO ? better visualization
    cfg = struct;
    cfg.method = 'hexahedral';
    cfg.tissue = {'gray'};
    cfg.numvertices = 5000;
    gray_mesh = ft_prepare_mesh(cfg, mriSegmented{s});
    gray_mesh = ft_convert_units(gray_mesh,'mm');

    fig = figure();
    title(['nSources = ' num2str(Infos{s}.sourcemodel.n_sources)])
    ft_plot_mesh(sourcemodels{s}.pos(sourcemodels{s}.inside,:));
    ft_plot_mesh(gray_mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3);
    view(115,15)
    print([imgPath{s} '\sources'],'-dpng')
    if ~visualize
        close(fig)
    end

    clear gray_mash;
    if strcmp(Config.mriSegmented.method{s}, 'mrtim')
        mriSegmented{s} = mriBackup; clear mriBackup
    end
end

%% Leadfield
for s = 1:nPath
    %% 1 Compute transfer matrix
    Infos{s}.leadfield.ft_prepare_vol_sens = true;
    [headmodel, elec] = ft_prepare_vol_sens(headmodels{s}, elecs{s});
    save([outputPath{s} '\headmodel'], 'headmodel');
    save([outputPath{s} '\elec'], 'elec');
    headmodels{s} = headmodel; clear headmodel
    elecs{s} = elec; clear elec
    
    %% 2 Compute leadfield
    cfg = struct;
    %cfg.grid = sourcemodels{s};
    cfg.sourcemodel = sourcemodels{s};
    cfg.headmodel = headmodels{s};
    cfg.elec = elecs{s};
    % cfg.reducerank = 3; % tutorial
    sourcemodel = ft_prepare_leadfield(cfg);
    cfg = rm_field_data(cfg, "sourcemodel");
    cfg = rm_field_data(cfg, "headmodel");
    cfg = rm_field_data(cfg, "elec");
    Infos{s}.leadfield.ft_prepare_leadfield.cfg = cfg;
    save([outputPath '\sourcemodel'], 'sourcemodel');
    sourcemodels{s} = sourcemodel; clear sourcemodel
end

%% Save info
for s = 1:nPath
    Info = Infos{s};
    save([outputPath '\info'], 'Info');
end
end
