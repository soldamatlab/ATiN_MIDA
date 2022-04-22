function [] = ft_seg_save(outputPath, fileName, varName, var)
assign_var(varName, var);
for i = 1:length(outputPath)
    save([outputPath{i} '\' fileName], varName);
end
end

