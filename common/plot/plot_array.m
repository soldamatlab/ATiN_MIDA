function [fig] = plot_array(array)
arraySize = size(array);
imageX = 1:arraySize(1);
imageY = 1:arraySize(2);

fig = figure;
imagesc(imageX,imageY,array)
colorbar
end
