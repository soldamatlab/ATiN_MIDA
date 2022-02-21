function [Config] = set_mri_path(Config, matlabbatch)
%SET_MRI_PATH
%Save path to the MRI file to 'Config.mriPath'
%
%MRI path has to be included in 'Config.mriPath' or
%'Config.mrtim.run.anat_image' or in the provided [matlabbatch].
%
%If multiple paths are provided, the path is set with priority as follows:
%'Config.mriPath' > 'Config.mrtim.run.anat_image' > [matlabbatch]
inMrtim = anat_image_in_config(Config);
inMatlabbatch = exist('matlabbatch', 'var') && anat_image_in_matlabbatch(matlabbatch);

if isfield(Config, 'mriPath')
    if inMrtim || inMatlabbatch
        warning("Multiple MRI file paths provided. Using 'Config.mriPath'.")
    end
    return
end

if inMrtim
    Config.mriPath = Config.mrtim.run.anat_image;
    if inMatlabbatch
        warning("Multiple MRI file paths provided. Using 'Config.mrtim.run.anat_image'.")
    end
    return
end

if inMatlabbatch
    Config.mriPath = matlabbatch{1}.spm.tools.spm_mrtim.run.anat_image;
    return
end

error("Missing MRI file path! Please, include it in 'Config.mriPath', 'Config.mrtim.run.anat_image' or in matlabbbatch included in 'Config.batch'!")
end

