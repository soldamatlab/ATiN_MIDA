function [fig] = plot_electrodes_aligned(mesh, elec_projected, elec_aligned)
fig = figure('Position', get(0, 'Screensize'));

fig=tiledlayout('flow');
nexttile
ft_plot_mesh(mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3)
ft_plot_sens(elec_projected,'facecolor','b','elecsize',20);
ft_plot_sens(elec_aligned,'facecolor','r','elecsize',20);
view(100,10)
nexttile
ft_plot_mesh(mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3)
ft_plot_sens(elec_projected,'facecolor','b','elecsize',20);
ft_plot_sens(elec_aligned,'facecolor','r','elecsize',20);
view(180,13)
nexttile
ft_plot_mesh(mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3)
ft_plot_sens(elec_projected,'facecolor','b','elecsize',20);
ft_plot_sens(elec_aligned,'facecolor','r','elecsize',20);
view(0,80)
nexttile
ft_plot_mesh(mesh,'surfaceonly',1,'facecolor', 'skin', 'edgecolor', 'none','facealpha',0.3)
ft_plot_sens(elec_projected,'facecolor','b','elecsize',20);
ft_plot_sens(elec_aligned,'facecolor','r','elecsize',20);
view(150,30)
end

