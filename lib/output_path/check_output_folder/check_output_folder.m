function [abort] = check_output_folder(outputPath)
if exist(outputPath, 'dir')
    abort = existing_folder_dialog(outputPath);
else
    abort = false;
    if ~mkdir(outputPath)
        error("Could not create output folder!")
    end
end
end

