function [outputPath, imgPath] = create_output_folder(outputPath, allowExistingFolder)
if ~exist('allowExistingFolder', 'var')
    allowExistingFolder = false;
end

if exist(outputPath, 'dir')
    if ~allowExistingFolder
        error("Output folder with given / generated name already exists!")
    end
elseif ~mkdir(outputPath)
    error("Could not create output folder!")
end

imgPath = [outputPath '\img'];
if ~mkdir(imgPath)
    error("Could not create image output folder!")
end
end

