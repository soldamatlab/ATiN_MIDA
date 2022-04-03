function [Config] = set_output_path(Config)
if isfield(Config, 'outputPath')
    % database structure fields won't be used for outputPath
    return
end

check_required_field(Config, 'resultsPath');
check_required_field(Config, 'analysisName');
check_required_field(Config, 'dataName');

if isfield(Config, 'runName')
    runName = Config.runName;
else
    runName = sprintf('run_%s', datestr(now, 'yyyy-mm-dd-HHMM'));
end

Config.outputPath = [Config.resultsPath '\' Config.analysisName '\' Config.dataName '\' runName];
end

