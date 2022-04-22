function [Config] = set_dialog_config(Config)
if isfield(Config, 'dialog')
    return
end

% Default option:
Config.dialog = true;
end

