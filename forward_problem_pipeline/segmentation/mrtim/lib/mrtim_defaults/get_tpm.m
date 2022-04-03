function [tpm] = get_tpm(mrtimPath, nLayers)
switch nLayers
   case 6
      tpm = [mrtimPath '\external\NET\template\tissues_MNI\eTPM6.nii,1'];
   case 12
      tpm = [mrtimPath '\external\NET\template\tissues_MNI\eTPM12.nii,1'];
    otherwise
        error("get_tpm support [nLayers] = 6 or 12")
end
end

