function [Mrtim] = fill_mrtim_defaults(Mrtim, mrtimPath)

DefaultMrtim = mrtim_defaults(mrtimPath);

if ~isfield(Mrtim, 'run')
    Mrtim.run = DefaultMrtim.run;
else
    if ~isfield(Mrtim.run, 'anat_image')
        % TODO
    end
    
    if ~isfield(Mrtim.run, 'prepro')
        Mrtim.run.prepro = DefaultMrtim.run.prepro;
    else
        if ~isfield(Mrtim.run.prepro, 'res')
            Mrtim.run.prepro.res = DefaultMrtim.run.prepro.res;
        end
        if ~isfield(Mrtim.run.prepro, 'smooth')
            Mrtim.run.prepro.smooth = DefaultMrtim.run.prepro.smooth;
        end
        if ~isfield(Mrtim.run.prepro, 'biasreg')
            Mrtim.run.prepro.biasreg = DefaultMrtim.run.prepro.biasreg;
        end
        if ~isfield(Mrtim.run.prepro, 'biasfwhm')
            Mrtim.run.prepro.biasfwhm = DefaultMrtim.run.prepro.biasfwhm;
        end
        if ~isfield(Mrtim.run.prepro, 'lowint')
            Mrtim.run.prepro.lowint = DefaultMrtim.run.prepro.lowint;
        end
    end
    
    if ~isfield(Mrtim.run, 'tpmopt')
        Mrtim.run.tpmopt = DefaultMrtim.run.tpmopt;
    else
        if ~isfield(Mrtim.run.tpmopt, 'tpmimg')
            Mrtim.run.tpmopt.tpmimg = DefaultMrtim.run.tpmopt.tpmimg;
        end
        if ~isfield(Mrtim.run.tpmopt, 'mrf')
            Mrtim.run.tpmopt.mrf = DefaultMrtim.run.tpmopt.mrf;
        end
        if ~isfield(Mrtim.run.tpmopt, 'cleanup')
            Mrtim.run.tpmopt.cleanup = DefaultMrtim.run.tpmopt.cleanup;
        end
    end
    
    if ~isfield(Mrtim.run, 'segtiss')
        Mrtim.run.segtiss = DefaultMrtim.run.segtiss;
    else
        if ~isfield(Mrtim.run.segtiss, 'gapfill')
            Mrtim.run.tpmopt.gapfill = DefaultMrtim.run.tpmopt.gapfill;
        end
        if ~isfield(Mrtim.run.segtiss, 'tiss_mask')
            Mrtim.run.tpmopt.tiss_mask = DefaultMrtim.run.tpmopt.tiss_mask;
        end
    end
end
end

