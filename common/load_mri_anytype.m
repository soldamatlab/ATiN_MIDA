function [mri] = load_mri_anytype(mri, varName)
mri = convertCharsToStrings(mri);
if isstring(mri)
    [~,~,ext] = fileparts(mri);
    if ext == ".mat"
        if ~exist('varName', 'var')
            error("[varName] has to be provided if [mri] is path to a '.mat' file.")
        end
        mri = load_var_from_mat(varName, mri);
    elseif ext == ".nii" || ext == ".dcm" || ext == ".IMA"
        mri = convertStringsToChars(mri);
        mri = ft_read_mri(mri);
    elseif ext == ".nhdr" || ext == ".nrrd"
        mri = load_nrrd_mri(mri);
    else
        error("Unsupported filetype of segmented MRI.")
    end
end

