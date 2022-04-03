function [Config] = set_mri_path(Config, matlabbatch)
%SET_MRI_PATH
%Save path to the MRI file to 'Config.mri'
%
%MRI path has to be included in 'Config.mri' or
%'Config.mrtim.run.anat_image' or in the provided [matlabbatch].
%
%If multiple paths are provided, the path is set with priority as follows:
%'Config.mri' > 'Config.mrtim.run.anat_image' > [matlabbatch]
inMrtim = anat_image_in_config(Config);
inMatlabbatch = exist('matlabbatch', 'var') && anat_image_in_matlabbatch(matlabbatch);

if isfield(Config, 'mri')
    if inMrtim || inMatlabbatch
        warning("Multiple MRI file paths provided. Using 'Config.mri'.")
    end
    return
end

if inMrtim
    Config.mri = Config.mrtim.run.anat_image;
    if inMatlabbatch
        warning("Multiple MRI file paths provided. Using 'Config.mrtim.run.anat_image'.")
    end
    return
end

if inMatlabbatch
    Config.mri = matlabbatch{1}.spm.tools.spm_mrtim.run.anat_image;
    return
end

error("Missing MRI file path! Please, include it in 'Config.mri', 'Config.mrtim.run.anat_image' or in matlabbbatch included in 'Config.batch'!")
end

