function [abort] = check_output_folder(outputPath)
if exist(outputPath, 'dir')
    quest = sprintf('Folder %s already exists! Do you want to proceed?', outputPath);
    answer=questdlg(quest,'Folder already exists!','Proceed','Abort','Abort');
    switch answer
      case 'Proceed'
      case 'Abort'
          disp("Pipeline aborted by user.")
          abort = true;
          return
        otherwise
          disp("Pipeline aborted by user. (Closing the Abort dialog aborts the pipeline too.)")
          abort = true;
          return
    end
else
    if ~mkdir(outputPath)
        error("Could not create output folder!")
    end
end
abort = false;
end

