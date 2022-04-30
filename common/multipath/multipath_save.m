function [] = multipath_save(outputPath, fileName, var, varName)
assign_var(varName, var);
for i = 1:length(outputPath)
    save([outputPath{i} '\' fileName], varName);
end
end
