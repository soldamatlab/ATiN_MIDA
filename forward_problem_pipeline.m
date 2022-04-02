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
Config = set_output_path(Config);
if check_output_folder(Config.outputPath)
    return
end
Config = set_paths(Config);
Config = set_visualize(Config);
save([Config.outputPath '\config'],'Config');

Info = struct;

%% Segmentation
Segmentation = struct;
if isfield(Config, 'segmentation')
    %% Load segmented MRI from file
    if isfield(Config.segmentation, 'file')
        disp("SEGMENTATION: Loading segmented MRI from file.")
        Segmentation.file = Config.segmentation.file;
    end
    
    %% FieldTrip
    if isfield(Config.segmentation, 'fieldtrip')
        disp("SEGMENTATION: FieldTrip")
        Info.segmentation.fieldtrip.finished = ...
        run_submodule(@segmentation_fieldtrip, Config.segmentation.fieldtrip, "FieldTrip segmentation");
        Segmentation.fieldtrip = segmentation2config('fieldtrip', Config.segmentation.fieldtrip.path.output);
    end

    %% MR-TIM
    if isfield(Config.segmentation, 'mrtim')
        disp("SEGMENTATION: MR-TIM")
        Info.segmentation.mrtim.finished = ...
        run_submodule(@segmentation_mrtim, Config.segmentation.mrtim, "MR-TIM segmentation");
        Segmentation.mrtim = segmentation2config('mrtim', Config.segmentation.mrtim.path.output);
    end
end

%% Model conductivity
if isfield(Config, 'model')
    %% FieldTrip
    if isfield(Config.model, 'fieldtrip')
        cfgModelFieldtrip = Config.model.fieldtrip;
        SegQueue = get_seg_queue(Config.model.fieldtrip.mriSegmented, Segmentation);
        queueFields = fieldnames(SegQueue);
        for f = 1:numel(queueFields)
            fprintf("CONDUCTIVITY MODELING: Fieldtrip with segmented MRI from %s\n", queueFields{f})
            cfgModelFieldtrip.mriSegmented = SegQueue.(queueFields{f});
            cfgModelFieldtrip.path.output = [Config.model.fieldtrip.path.output '\' queueFields{f} '_segmentation'];
            Info.model.fieldtrip.(queueFields{f}).finished = ...
            run_submodule(@model_fieldtrip, cfgModelFieldtrip, "FieldTrip conductivity modeling");
        end
    end
end

%% Save info
save([Config.outputPath '\info'],'Info');

end

