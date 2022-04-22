function [fig] = plot_segmentation(Config, mriSegmented, anatomy)
% PLOT_SEGMENTATION
% Options:
% Config.location
% Config.colormap
% Config.visualize
% Config.name
% Config.save - string or array of strings (for multiple saves)

%% Defaults
visualize = true;
cfg = struct;
cfg.location = 'center';
cfg.funparameter = 'tissue';
cfg.funcolormap  = lines;

%% Config
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

