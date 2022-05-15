function [fig] = plot_segmentation(Config, segmentation, anatomy)
% PLOT_SEGMENTATION
% Required:
%   segmentation
%
% Optional:
%   anatomy
%
% Optional Config:
%   Config.colormap
%  or
%   Config.method & Config.nLayres - to set colormap from const_color.m
%
%   Config.plotmethod
%   Config.location
%   Config.crosshair
%   Config.visualize
%   Config.name
%   Config.save - string or array of strings (for multiple saves)

%% Defaults
visualize = true;
cfg = struct;
cfg.location = 'center';
cfg.crosshair = 'no';
cfg.funparameter = 'tissue';
cfg.funcolormap  = lines;

%% Config
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end
if isfield(Config, 'plotmethod')
    cfg.method = Config.plotmethod;
end
if isfield(Config, 'location')
    cfg.location = Config.location;
end
if isfield(Config, 'crosshair')
    cfg.crosshair = Config.crosshair;
end
if isfield(Config, 'colormap')
    cfg.funcolormap = Config.colormap;
elseif isfield(Config, 'method') && isfield(Config, 'nLayers')
    cfg.funcolormap = get_colormap(Config);
    cfg.colormap = cfg.funcolormap;
else
    warning("Add 'Config.colormap' parameter. Using default color map - some layers may have the same color.")
end

%% Plot
fig = figure;
if exist('anatomy', 'var')
    ft_sourceplot(cfg, segmentation, anatomy);
else
    ft_sourceplot(cfg, segmentation);
end
if isfield(Config, 'name')
    set(fig, 'Name', Config.name)
end

%% Save
if isfield(Config, 'save')
    Config.save = convertCharsToStrings(Config.save);
    for s = 1:length(Config.save)
        if iscell(Config.save)
            print(Config.save{s}, '-dpng', '-r300')
        else
            print(Config.save(s), '-dpng', '-r300')
        end
    end
end
if ~visualize
    close(fig)
end
end

