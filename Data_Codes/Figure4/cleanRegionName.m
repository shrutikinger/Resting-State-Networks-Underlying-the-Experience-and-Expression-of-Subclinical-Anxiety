function cleanName = cleanRegionName(name)
    % Replace left/right
    cleanName = strrep(name, 'left', 'L');
    cleanName = strrep(cleanName, 'Hippocampus', 'hpc');
    cleanName = strrep(cleanName, 'Amygdala', 'amg');
    cleanName = strrep(cleanName, 'right', 'R');
    % Remove the word "Area" (case sensitive)
    cleanName = strrep(cleanName, 'Area ', '');

end
