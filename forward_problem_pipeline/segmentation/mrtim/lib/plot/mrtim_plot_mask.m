function [] = mrtim_plot_mask(name, tissueMasksPath, masksImgPath, visualize)
mask = [tissueMasksPath '\' name '.nii'];
cfg = struct;
cfg.name = name;
cfg.save = [masksImgPath '\' name];
cfg.visualize = visualize;
plot_mask(cfg, mask);
end

