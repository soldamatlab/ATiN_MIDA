function [fig] = plot_mask(Config, mask)
%% Load mask
[mask] = load_mri_anytype(mask);

%% Defaults
visualize = true;
cfg = [];
cfg.funparameter = 'anatomy';
cfg.location = 'center';
cfg.crosshair = 'no';
cfg.funcolormap = spring(2);

%% Config
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end
if isfield(Config, 'parameter')
    cfg.funparameter = Config.parameter;
end
if isfield(Config, 'location')
    cfg.funcolormap = Config.location;
end
if isfield(Config, 'crosshair')
    cfg.crosshair = Config.crosshair;
end
if isfield(Config, 'colormap')
    cfg.funcolormap = Config.colormap;
end

%% Plot
fig = figure;
ft_sourceplot(cfg, mask);
if isfield(Config, 'name')
    set(fig, 'Name', [Config.name ' mask'])
end
caxis([0 1])

%% Save
if isfield(Config, 'save')
    print(Config.save, '-dpng', '-r300')
end
if ~visualize
    close(fig)
end
end

