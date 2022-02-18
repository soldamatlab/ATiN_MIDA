function [] = check_paths(Config)
check_required_field(Config, 'spmPath');
check_required_field(Config, 'mrtimPath');

ANAT_IMAGE_ERROR = "Missing path to the MRI! Please, include it in 'Config.mriPath' or 'Config.mrtim.run.anat_image'!";
if ~isfield(Config, 'mriPath')
    if isfield(Config, 'mrtim')
        if isfield(Config.mrtim, 'run')
            if ~isfield(Config.mrtim.run, 'anat_image')
                error(ANAT_IMAGE_ERROR)
            end
        else
            error(ANAT_IMAGE_ERROR)
        end
    else
        error(ANAT_IMAGE_ERROR)
    end
    
    Config.mriPath = Config.mrtim.run.anat_image;
end
end

