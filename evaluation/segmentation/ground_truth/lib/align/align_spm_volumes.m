function [mriPrepro, mriSegmented] = align_spm_volumes(Config)
mriPrepro = Config.mriPrepro;
groundTruthPrepro = Config.groundTruthPrepro;

mriPrepro.transform(2,:) = -mriPrepro.transform(2,:);
cfg = struct;
cfg.method = 'spm';
mriPrepro = ft_volumerealign(cfg, mriPrepro, groundTruthPrepro);

if isfield(Config, 'mriSegmented')
    mriSegmented = Config.mriSegmented;
    mriSegmented.transform = mriPrepro.transform;
end
end

