function [fig] = plot_mask(Config, mask)
%% Load mask
if isstring(mask)
    mask = ft_read_mri(mask);
end

%% Defaults
visualize = true;
cfg = [];
cfg.funparameter = 'anatomy';
cfg.location = 'center';
cfg.funcolormap = spring(2);

%% Config
if isfield(Config, 'visalize')
    visualize = Config.visualize;
end
if isfield(Config, 'parameter')
    cfg.funparameter = Config.parameter;
end
if isfield(Config, 'location')
    cfg.funcolormap = Config.location;
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

%% Save
if isfield(Config, 'save')
    print(Config.save, '-dpng', '-r300')
end
if ~visualize
    close(fig)
end
end

