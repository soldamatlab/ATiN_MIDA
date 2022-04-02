function [abort] = check_output_folder(outputPath, existingFolderDialog)
if ~exist('existingFolderDialog', 'var')
    existingFolderDialog = true;
end

if exist(outputPath, 'dir')
    if existingFolderDialog
        abort = existing_folder_dialog(outputPath);
    end
else
    abort = false;
    if ~mkdir(outputPath)
        error("Could not create output folder!")
    end
end
end

