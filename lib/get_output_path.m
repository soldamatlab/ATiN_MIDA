function [outputPath] = get_output_path(Config)
check_required_field(Config, 'resultsPath');
check_required_field(Config, 'analysisName');
check_required_field(Config, 'dataName');

if isfield(Config, 'runName')
    runName = Config.runName;
else
    runName = sprintf('run_%s', datestr(now, 'yyyy-mm-dd-HHMM'));
end

outputPath = [Config.resultsPath '\' Config.analysisName '\' Config.dataName '\' runName];
end

