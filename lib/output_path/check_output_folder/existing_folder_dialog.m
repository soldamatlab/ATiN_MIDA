function [abort] = existing_folder_dialog(outputPath)
quest = sprintf('Folder %s already exists! Do you want to proceed?', outputPath);
answer=questdlg(quest,'Folder already exists!','Proceed','Abort','Abort');
switch answer
  case 'Proceed'
      abort = false;
  case 'Abort'
      disp("Pipeline aborted by user.")
      abort = true;
      return
    otherwise
      disp("Pipeline aborted by user. (Closing the Abort dialog aborts the pipeline too.)")
      abort = true;
      return
end
end

