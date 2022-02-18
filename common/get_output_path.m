function [outputPath, imgPath] = get_output_path(Config)
check_required_field(Config, 'resultsPath');
check_required_field(Config, 'analysisName');
check_required_field(Config, 'dataName');

if isfield(Config, 'runName')
    runName = Config.runName;
else
    runName = sprintf('run_%s', datestr(now, 'yyyy-mm-dd-HHMM'));
end

outputPath = [Config.resultsPath '\' Config.analysisName '\' Config.methodName '\' Config.dataName '\' runName];

if exist(outputPath, 'dir')
    error("Output folder with given / generated name already exists!")
end
if ~mkdir(outputPath)
    error("Could not create output folder!")
end

imgPath = [outputPath '\img'];
if ~mkdir(imgPath)
    error("Could not create image output folder!")
end
end

