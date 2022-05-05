function [mriSegmented] = segmentation_fieldtrip(Config)
%% SEGMENTATION_FIELDTRIP
%
% Required:
%   Config.mri       = path to mri, will be preprocessed by FT
% or
%   Config.mriPrepro = path to mri, won't be preprocessed
%
%   Config.nLayers   = 3, 5 or [3, 5]
%   Config.output
%
%   Optional:
%   Config.coordsys   - if set will overwrite mri.coordsys with given value
%   Config.suffix
%   Config.visualize

%% Init
addpath_source;

%% Check Config
if isfield(Config, 'mriPrepro')
    preprocess = false;
elseif isfield(Config, 'mri')
    preprocess = true;
else
    error("Both [Config.mri] and [Config.mriPrepro] are missing. Add mri to be segmented.")
end

    
check_required_field(Config, 'output');
suffix = '';
if isfield(Config, 'suffix')
    Config.suffix = convertStringsToChars(Config.suffix);
    suffix = ['_' Config.suffix];
end
Config = ft_seg_set_nlayers(Config);
if iscell(Config.nLayers)
    Config.nLayers = cell2mat(Config.nLayers);
end
nNLayers = length(Config.nLayers);
outputFieldName = cell(1, nNLayers);
outputPath = cell(1, nNLayers);
imgPath = cell(1, nNLayers);
for i = 1:length(Config.nLayers)
    outputFieldName{i} = ['output' num2str(Config.nLayers(i)) 'layers'];
    Config.(outputFieldName{i}) = [Config.output '\fieldtrip' num2str(Config.nLayers(i)) suffix];
    [outputPath{i}, imgPath{i}] = create_output_folder(Config.(outputFieldName{i}));
end

if ~isfield(Config, 'visualize')
    Config.visualize = false;
end

Config.method = 'fieldtrip';
multipath_save(outputPath, 'config', Config, 'Config');
Info = struct;

if preprocess
    %% Read MRI
    mriOriginal = load_mri_anytype(Config.mri);
    if isfield(Config, 'coordsys')
        mriOriginal.coordsys = Config.coordsys;
    end
    if isfield(mriOriginal, 'coordsys') && strcmp(mriOriginal.coordsys, 'scanras') % FT throws errors with scanras
        mriOriginal.coordsys = 'acpc';
        warning("Replacing MRI.coordsys 'scanras' with 'acpc'.")
    end
    multipath_save(outputPath, 'mri_original', mriOriginal, 'mriOriginal');

    %% visualize
    cfg = struct;
    %cfg.funparameter = 'anatomy';
    %cfg.colormap = spring;
    cfg.location = 'center';
    cfg.crosshair = 'no';
    fig = figure;
    ft_sourceplot(cfg, mriOriginal);
    set(fig, 'Name', 'MRI original')
    multipath_print(imgPath, 'mri_original');
    if ~Config.visualize
        close(fig)
    end

    %% Preprocess
    cfg = struct;
    cfg.outputPath = outputPath;
    cfg.imgPath = imgPath;
    cfg.visualize = Config.visualize;
    [mriPrepro, Info] = preprocess_fieldtrip(cfg, mriOriginal, Info);
    
else
    %% Read preprocessed MRI
    mriPrepro = load_mri_anytype(Config.mriPrepro);
    if isfield(Config, 'coordsys')
        mriPrepro.coordsys = Config.coordsys;
    end
    if isfield(mriPrepro, 'coordsys') && mriPrepro.coordsys == "scanras" % FT throws errors with scanras
        mriPrepro.coordsys = 'acpc';
        warning("Replacing MRI.coordsys 'scanras' with 'acpc'.")
    end
    multipath_save(outputPath, 'mri_prepro', mriPrepro, 'mriPrepro');
    
    %% visualize
    cfg = struct;
    cfg.location = 'center';
    cfg.crosshair = 'no';
    fig = figure;
    ft_sourceplot(cfg, mriPrepro);
    set(fig, 'Name', 'Preprocessed MRI')
    multipath_print(imgPath, 'mri_prepro');
    if ~Config.visualize
        close(fig)
    end
end

%% Segment the MRI
for i = 1:length(Config.nLayers)
    cfg = struct;
    cfg.nLayers = Config.nLayers(i);
    cfg.outputPath = outputPath{i};
    cfg.imgPath = imgPath{i};
    cfg.visualize = Config.visualize;
    [mriSegmented, Info] = segment_fieldtrip(cfg, mriPrepro, Info);
    
    %% Save Info
    save([outputPath{i} '\info'], 'Info');
end
end
