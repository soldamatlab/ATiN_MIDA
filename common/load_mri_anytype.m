function [mri] = load_mri_anytype(mri)
mri = convertCharsToStrings(mri);
if isstring(mri)
    [~,~,ext] = fileparts(mri);
    if ext == ".mat"
        mri = load_var_from_mat('mriSegmented', mri);
    elseif ext == ".nii" || ext == ".dcm" || ext == ".IMA"
        mri = ft_read_mri(mri);
    elseif ext == ".nhdr" || ext == ".nrrd"
        mri = load_nrrd_mri(mri);
    else
        error("Unsupported filetype of segmented MRI.")
    end
end

