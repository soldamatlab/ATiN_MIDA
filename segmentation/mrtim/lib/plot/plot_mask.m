function [] = plot_mask(name, tissueMasksPath, masksImgPath, visualize)
mask = ft_read_mri([tissueMasksPath '\' name '.nii']);

cfg = [];
cfg.funparameter = 'anatomy';
cfg.funcolormap = spring;
cfg.location = 'center';

fig = figure;
ft_sourceplot(cfg, mask);
print([masksImgPath '\' name],'-dpng','-r300')
if ~visualize
    close(fig)
end
end

