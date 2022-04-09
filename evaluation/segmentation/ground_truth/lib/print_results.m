function [] = print_results(Config, result, label)
fprintf("\n")
fprintf("______________________________\n")
fprintf("GROUND TRUTH EVALUATION RESULT\n")
fprintf("Segmentation method: %s\n", Config.mriSegmented.method)
fprintf("Number of layers:    %d\n", Config.mriSegmented.nLayers)
fprintf("______________________________\n")

for l = 1:length(label)
    fprintf("   %s\n", label{l})
    fprintf("Absolute error:      %d / %d voxels\n", result.absoluteError.(label{l}), result.numel.(label{l}))
    fprintf("Realtive error:      %f\n\n", result.relativeError.(label{l}))
end
fprintf("   Sum of all masks\n")
fprintf("Absolute error:      %d / %d voxels\n", result.absoluteError.maskSum, result.numel.maskSum)
fprintf("Realtive error:      %f\n", result.relativeError.maskSum)
fprintf("______________________________\n")
end

