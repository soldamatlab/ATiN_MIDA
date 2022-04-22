function [Config] = set_output_path(Config)
if isfield(Config, 'output')
    % database structure fields won't be used for outputPath
    return
end

check_required_field(Config, 'resultsPath');
check_required_field(Config, 'dataName');
check_required_field(Config, 'subjectName');

runFolder = false;
if isfield(Config, 'runName')
    Config.runName = convertStringsToChars(Config.runName);
    if ischar(Config.runName)
        runName = Config.runName;
        runFolder = true;
    elseif isa(Config.runName, 'logical') && Config.runName
        runName = sprintf('run_%s', datestr(now, 'yyyy-mm-dd-HHMM'));
        runFolder = true;
    end
end

if runFolder
    Config.output = [Config.resultsPath '\' Config.dataName '\' Config.subjectName '\' runName];
else
    Config.output = [Config.resultsPath '\' Config.dataName '\' Config.subjectName];
end
end

