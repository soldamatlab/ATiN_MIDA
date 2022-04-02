function [Config] = set_dialog_config(Config)
if isfield(Config, 'miscellaneous')
    if isfield(Config.miscellaneous, 'dialog')
        return
    end
end

% Default option:
Config.miscellaneous.dialog = true;
end

