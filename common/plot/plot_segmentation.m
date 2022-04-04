function [fig] = plot_segmentation(Config, mriSegmented, anatomy)
%% Defaults
visualize = true;
cfg = struct;
cfg.location = 'center';
cfg.funparameter = 'seg';
cfg.funcolormap  = lines;

%% Config
if exist('Config', 'var')
    if isfield(Config, 'visualize')
        visualize = Config.visualize;
    end
    if isfield(Config, 'location')
        cfg.location = Config.location;
    end
    if isfield(Config, 'colormap')
        cfg.funcolormap = Config.colormap;
    else
        warning("Add 'Config.funcolormap' parameter. Using default color map - some layers may have the same color.")
    end
end

%% Prepare Segmentation
segmentation = prepare_segmentation(mriSegmented);

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
    print(Config.save, '-dpng', '-r300')
end
if ~visualize
    close(fig)
end
end

