function [outputPath, imgPath] = create_output_folder(outputPath)
if exist(outputPath, 'dir')
    error("Output folder with given / generated name already exists!")
end
if ~mkdir(outputPath)
    error("Could not create output folder!")
end

imgPath = [outputPath '\img'];
if ~mkdir(imgPath)
    error("Could not create image output folder!")
end
end

