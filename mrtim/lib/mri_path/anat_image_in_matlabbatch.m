function [found] = anat_image_in_matlabbatch(matlabbatch)
found = false;
if ~isfield(matlabbatch{1}, 'spm'); return; end
if ~isfield(matlabbatch{1}.spm, 'tools'); return; end
if ~isfield(matlabbatch{1}.spm.tools, 'spm_mrtim'); return; end
if ~isfield(matlabbatch{1}.spm.tools.spm_mrtim, 'run'); return; end
if ~isfield(matlabbatch{1}.spm.tools.spm_mrtim.run, 'anat_image'); return; end
found = true;
end

