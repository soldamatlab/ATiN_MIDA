function [] = forward_problem_pipeline(Config)
%FORWARD_PROBLEM_PIPELINE TODO Summary of this function
%
% Required:
%   Config.output - Output path as string. This option takes priority if both are present.
%    or
%   Config.resultsPath
%   Config.dataName - Output path is then determined as [resultsPath\analysisName\dataName\runName]
%   Config.subjectName
%   Config.runName
%
% Optional:
%   TODO
%
%   Config.miscellaneous.visualize
%   Config.miscellaneous.dialog - Disables user dialog in case of already existing output folder.
%                                 Useful for automatic runs of the pipeline.
%

%% Import
addpath_source;

%% Config
Config = set_output_path(Config);
Config = set_dialog_config(Config);
if check_output_folder(Config.output, Config.dialog)
    return
end
Config = set_paths(Config);
Config = set_visualize(Config);
save([Config.output '\pipeline_config'],'Config');

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
        Info.segmentation.fieldtrip.finished = ...
        run_submodule(@segmentation_fieldtrip, Config.segmentation.fieldtrip, "SEGMENTAITON FieldTrip");
        if Info.segmentation.fieldtrip.finished
            Segmentation.fieldtrip = segmentation2config('fieldtrip', Config.segmentation.fieldtrip.output);
        end
    end

    %% MR-TIM
    if isfield(Config.segmentation, 'mrtim')
        Info.segmentation.mrtim.finished = ...
        run_submodule(@segmentation_mrtim, Config.segmentation.mrtim, "SEGMENTATION MR-TIM");
        if Info.segmentation.mrtim.finished
            Segmentation.mrtim = segmentation2config('mrtim', Config.segmentation.mrtim.output);
        end
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
            cfgModelFieldtrip.mriSegmented = SegQueue.(queueFields{f});
            cfgModelFieldtrip.path.output = [Config.model.fieldtrip.output '\' queueFields{f} '_segmentation'];
            submoduleName = sprintf("CONDUCTIVITY MODELING Fieldtrip with segmentationx`     from %s\n", queueFields{f});
            Info.model.fieldtrip.(queueFields{f}).finished = ...
            run_submodule(@model_fieldtrip, cfgModelFieldtrip, submoduleName);
        end
    end
end

%% Save info
save([Config.output '\pipeline_info'],'Info');

end

