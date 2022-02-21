function [Mrtim] = mrtim_defaults(mrtimPath)
%MRTIM_DEFAULTS defindes default settings of MR-TIM

    % NO DEFAULTS:
    % Mrtim.run.anat_image = {};
    % Mrtim.run.output_folder = {};
    
    Mrtim.run.prepro.res = 1;
    Mrtim.run.prepro.smooth = 1;
    Mrtim.run.prepro.biasreg = 0.001;
    Mrtim.run.prepro.biasfwhm = 30;
    Mrtim.run.prepro.lowint = 5;

    Mrtim.run.tpmopt.tpmimg = {[mrtimPath '\external\NET\template\tissues_MNI\eTPM12.nii,1']};
    Mrtim.run.tpmopt.mrf = 1;
    Mrtim.run.tpmopt.cleanup = 1;

    Mrtim.run.segtiss.gapfill = 1;
    Mrtim.run.segtiss.tiss_mask = 1;
end

