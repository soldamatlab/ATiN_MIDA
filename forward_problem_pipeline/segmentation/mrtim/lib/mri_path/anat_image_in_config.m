function [found] = anat_image_in_config(Config)
found = false;
if ~isfield(Config, 'mrtim'); return; end
if ~isfield(Config.mrtim, 'run'); return; end
if ~isfield(Config.mrtim.run, 'anat_image'); return; end
found = true;
end

