function [outputArg1,outputArg2] = create_sourcemodel(mriSegmented, units, imgPath, visualize)
cfg = struct;
%cfg.method = 'basedonmri' % is determined automatically from specified cfg options
cfg.resolution = .6; % Shaine has 6 mm % tutorial: 7.5
% TODO doc says 'cfg.resolution' is in 'mm', this works as intended though
cfg.mri = mriSegmented;
cfg.smooth = 0; % tutorial: 5
%cfg.threshold = 0.1; % is default
%cfg.inwardshift = 1; % tutorial, shifts dipoles away from surfaces

%cfg.elec = elec;
%cfg.headmodel = headmodel; TODO ?

sourcemodel = ft_prepare_sourcemodel(cfg);
sourcemodel = ft_convert_units(sourcemodel,units);
info.sourcemodel.n_sources = sum(sourcemodel.inside);

%% visualize
% TODO ? better visualization
cfg = struct;
cfg.method = 'hexahedral';
cfg.tissue = {'gray'};
cfg.numvertices = 5000;
gray_mesh = ft_prepare_mesh(cfg, mriSegmented);
gray_mesh = ft_convert_units(gray_mesh,units);

fig = figure();
title(['nSources = ' num2str(info.sourcemodel.n_sources)])
ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:));
ft_plot_mesh(gray_mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3);
view(115,15)
print([imgPath '\sources'],'-dpng')

if ~visualize
    close(fig)
end
end

