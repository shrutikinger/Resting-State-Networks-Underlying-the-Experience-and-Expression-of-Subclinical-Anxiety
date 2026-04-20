function name = getRegionName(code, mapData)
    % Extract number from 'JB133' or 'JB.171'
    expr = 'JB\.?(\d+)';  
    tokens = regexp(code, expr, 'tokens');
    if ~isempty(tokens)
        idx = str2double(tokens{1}{1});
        % Look up in table
        row = mapData(mapData.map_index == idx, :);
        if ~isempty(row)
            name = row.region_name{1};
        else
            name = code; % keep original if not JBxx
        end
    else
        name = code; % keep original if not JBxx
    end
end
