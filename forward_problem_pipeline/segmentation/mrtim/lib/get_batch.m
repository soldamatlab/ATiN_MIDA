function [matlabbatch] = get_batch(Config)
mriPath = [Config.mri ',1'];

if isfield(Config, 'batch')
    matlabbatch = Config.batch;
    if Config.fillBatch
        matlabbatch{1}.spm.tools.spm_mrtim.run.anat_image = {mriPath};
        matlabbatch{1}.spm.tools.spm_mrtim.run.output_folder = {Config.output};
    end
else
    if isfield(Config, 'mrtim')
        Mrtim = fill_mrtim_defaults(Config.mrtim, Config.path.mrtim, Config.nLayers);
    else
        Mrtim = mrtim_defaults(Config.path.mrtim, Config.nLayers);
    end
    Mrtim.run.anat_image = {mriPath};
    Mrtim.run.output_folder = {Config.output};
    matlabbatch{1}.spm.tools.spm_mrtim = Mrtim;
end
end

