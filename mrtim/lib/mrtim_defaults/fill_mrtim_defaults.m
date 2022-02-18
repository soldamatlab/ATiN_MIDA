function [Mrtim] = fill_mrtim_defaults(Mrtim, mrtimPath)

DefaultMrtim = mrtim_defaults(mrtimPath);

if ~isfield(Mrtim, 'run')
    Mrtim.run = DefaultMrtim.run;
else
    if ~isfield(Mrtim.run, 'anat_image')
        % TODO
    end
    
    if ~isfield(Mrtim.run, 'prepro')
        Mrtim.run.prepro = DefautlMrtim.run.prepro;
    else
        if ~isfield(Mrtim.run.prepro, 'res')
            Mrtim.run.prepro.res = DefautlMrtim.run.prepro.res;
        end
        if ~isfield(Mrtim.run.prepro, 'smooth')
            Mrtim.run.prepro.smooth = DefautlMrtim.run.prepro.smooth;
        end
        if ~isfield(Mrtim.run.prepro, 'biasreg')
            Mrtim.run.prepro.biasreg = DefautlMrtim.run.prepro.biasreg;
        end
        if ~isfield(Mrtim.run.prepro, 'biasfwhm')
            Mrtim.run.prepro.biasfwhm = DefautlMrtim.run.prepro.biasfwhm;
        end
        if ~isfield(Mrtim.run.prepro, 'lowint')
            Mrtim.run.prepro.lowint = DefautlMrtim.run.prepro.lowint;
        end
    end
    
    if ~isfield(Mrtim.run, 'tpmopt')
        Mrtim.run.tpmopt = DefautlMrtim.run.tpmopt;
    else
        if ~isfield(Mrtim.run.tpmopt, 'tpmimg')
            Mrtim.run.tpmopt.tpmimg = DefautlMrtim.run.tpmopt.tpmimg;
        end
        if ~isfield(Mrtim.run.tpmopt, 'mrf')
            Mrtim.run.tpmopt.mrf = DefautlMrtim.run.tpmopt.mrf;
        end
        if ~isfield(Mrtim.run.tpmopt, 'cleanup')
            Mrtim.run.tpmopt.cleanup = DefautlMrtim.run.tpmopt.cleanup;
        end
    end
    
    if ~isfield(Mrtim.run, 'segtiss')
        Mrtim.run.segtiss = DefautlMrtim.run.segtiss;
    else
        if ~isfield(Mrtim.run.segtiss, 'gapfill')
            Mrtim.run.tpmopt.gapfill = DefautlMrtim.run.tpmopt.gapfill;
        end
        if ~isfield(Mrtim.run.segtiss, 'tiss_mask')
            Mrtim.run.tpmopt.tiss_mask = DefautlMrtim.run.tpmopt.tiss_mask;
        end
    end
end
end

