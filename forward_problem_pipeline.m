function [] = forward_problem_pipeline(Config)
%FORWARD_PROBLEM_PIPELINE TODO Summary of this function
%   TODO Detailed explanation
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath([wd '\lib']));
addpath([wd '\common']);
addpath([wd '\segmentation\fieldtrip']);
addpath([wd '\segmentation\mrtim']);
addpath([wd '\model\fieldtrip']);

%% Config
% TODO check number of segmentation and model methods
outputPath = get_output_path(Config);
segmentationPath = [outputPath '\segmentation'];
segmentationFieldtripPath = [segmentationPath '\fieldtrip'];
segmentationMrtimPath = [segmentationPath '\mrtim'];
modelPath = [outputPath '\model'];
modelFieldtripPath = [modelPath '\fieldtrip'];

Config = set_visualize(Config);

Info = struct;

%% Segmentation
% TODO ? run config checks for user
Segmentation = struct;
if isfield(Config, 'segmentation')
    if isfield(Config.segmentation, 'file')
        disp("TEST") % TODO delete
        disp("SEGMENTATION: Loading segmented MRI from file.")
        Segmentation.file = Config.segmentation.file;
    end
    
    if isfield(Config.segmentation, 'fieldtrip')
        disp("SEGMENTATION: FieldTrip")
        Config.segmentation.fieldtrip.path.output = segmentationFieldtripPath;
        Info.segmentation.fieldtrip.finished = ...
        run_submodule(@segmentation_fieldtrip, Config.segmentation.fieldtrip, "FieldTrip segmentation");
        Segmentation.fieldtrip = segmentation2config('fieldtrip', segmentationFieldtripPath);
    end

    if isfield(Config.segmentation, 'brainstorm')
        disp("SEGMENTATION: Brainstorm")
        % TODO implement
        warning("Segmentation with Brainstorm is not yet implemented. Skipping.")
    end

    if isfield(Config.segmentation, 'mrtim')
        disp("SEGMENTATION: MR-TIM")
        Config.segmentation.mrtim.path.output = segmentationMrtimPath;
        Info.segmentation.mrtim.finished = ...
        run_submodule(@segmentation_mrtim, Config.segmentation.mrtim, "MR-TIM segmentation");
        Segmentation.mrtim = segmentation2config('mrtim', segmentationMrtimPath);
    end
end

%% Model conductivity
if isfield(Config, 'model')
    if isfield(Config.model, 'fieldtrip')
        Config.model.fieldtrip.path.output = modelFieldtripPath;
        cfgModelFieldtrip = Config.model.fieldtrip;
        SegQueue = get_seg_queue(Config.model.fieldtrip.mriSegmented, Segmentation);
        queueFields = fieldnames(SegQueue);
        for f = 1:numel(queueFields)
            fprintf("CONDUCTIVITY MODELING: Fieldtrip with segmented MRI from %s\n", queueFields{f})
            cfgModelFieldtrip.mriSegmented = SegQueue.(queueFields{f});
            Info.model.fieldtrip.(queueFields{f}).finished = ...
            run_submodule(@model_fieldtrip, cfgModelFieldtrip, "FieldTrip conductivity modeling");
        end
    end

    if isfield(Config.model, 'brainstorm')
        disp("CONDUCTIVITY MODELING: Brainstorm")
        % TODO implement
        warning("Conductivity modeling with Brainstorm is not yet implemented. Skipping.")
    end
end

%% Save additional files
save([outputPath '\config'],'Config');
save([outputPath '\info'],'Info');

end

