    function [Mrtim] = mrtim_defaults(mrtimPath, nLayers)
%MRTIM_DEFAULTS defindes default settings of MR-TIM

    % NO DEFAULTS:
    % Mrtim.run.anat_image = {};
    % Mrtim.run.output_folder = {};
    
    Mrtim.run.prepro.res = 1; % same as taberna2021
    Mrtim.run.prepro.smooth = 1; % same as taberna2021
    Mrtim.run.prepro.biasreg = 0.001; % default, not specified in taberna2021
    Mrtim.run.prepro.biasfwhm = 30; % default, not specified in taberna2021
    Mrtim.run.prepro.lowint = 5; % same as taberna2021

    Mrtim.run.tpmopt.tpmimg = {get_tpm(mrtimPath, nLayers)};
    Mrtim.run.tpmopt.mrf = 1;
    Mrtim.run.tpmopt.cleanup = 1;

    Mrtim.run.segtiss.gapfill = 1;
    Mrtim.run.segtiss.tiss_mask = 1;
end

