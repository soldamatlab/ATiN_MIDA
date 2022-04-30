function [] = multipath_print(outputPath, fileName)
for i = 1:length(outputPath)
    print([outputPath{i} '\' fileName],'-dpng','-r300')
end
end

