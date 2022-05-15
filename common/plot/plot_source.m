function [fig] = plot_source(Config, source)
% PLOT_SOURCE
%
% Required:
%   source
%
%   Config.parameter
%
% Optional:
%   Config.mri       = add mri to plot sources on
%   Config.visualize = true (default)
%   Config.name
%   Config.save      = filepath as string, set to save figure
%   Config.location
%   Config.crosshair = 'no' (default), set 'yes' to show crosshair
%   Config.visible

%% Config
check_required_field(Config, 'parameter');

if ~isfield(Config, 'crosshair')
    Config.crosshair = 'no'; % default
end

if ~isfield(Config, 'visualize')
    Config.visualize = true; % default
end

if ~isfield(Config, 'visible')
    Config.visible = true; % default
end

%% Plot
cfg = struct;
cfg.funparameter = Config.parameter;
cfg.crosshair = Config.crosshair;
cfg.visible = Config.visible;
if isfield(Config, 'location')
    cfg.location = Config.location;
end
fig = figure();
if isfield(Config, 'mri')
    ft_sourceplot(cfg, source, Config.mri)
else
    ft_sourceplot(cfg, source)
end
if isfield(Config, 'name')
    set(fig, 'Name', Config.name)
end
if isfield(Config, 'save')
    print(Config.save,'-dpng')
end
if ~Config.visualize
    close(fig)
    clear fig
end
end
