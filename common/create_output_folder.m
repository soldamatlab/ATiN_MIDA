function [outputPath, imgPath] = create_output_folder(outputPath, allowExistingFolder, imgFolder)
if ~exist('allowExistingFolder', 'var')
    allowExistingFolder = false;
end
if ~exist('imgFolder', 'var')
    imgFolder = true;
end

if exist(outputPath, 'dir')
    if ~allowExistingFolder
        error("Output folder with given / generated name already exists!")
    end
elseif ~mkdir(outputPath)
    error("Could not create output folder!")
end

if imgFolder
    imgPath = [outputPath '\img'];
    if ~exist(imgPath, 'dir')
        if ~mkdir(imgPath)
            error("Could not create image output folder!")
        end
    end
else
    imgPath = '';
end
end
