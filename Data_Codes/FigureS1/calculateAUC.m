function sum_auc = calculateAUC(signal,  thr)
    %
    % Inputs:
    %   signal - the SCR data signal (vector
    %   thr - the threshold for SCR onset (scalar)
    %
    % Output:
    %   sum_auc - the total calculated AUC (scalar)
    
    sum_auc = 0;
    
    % Handle outliers
    signal_zscore = zscore(signal);
    signal_outliers = find(signal_zscore > 3);
    signal(signal_outliers) = 0;

    auc_list = [];  % Area under the curve list
    start_idx = 1;  % First index
    time_axis = 1:length(signal);

    while start_idx <= length(signal)
        % Find onset of SCR (first value >= threshold)
        idx1 = find(signal(start_idx:end) >= thr, 1) + start_idx - 1;

        if isempty(idx1)
            plot(signal, 'ko', 'MarkerSize', 4)
            break;
        end

        % Find offset of SCR (first value < threshold after onset)
        end_idx = find(signal(idx1:end) < thr, 1) + idx1 - 1;

        if isempty(end_idx)
            end_idx = length(signal);  % If no offset found, use end of signal
        end

        if idx1 > 1
            idx1 = idx1 - 1;
        end

        % Indices from onset to offset
        range_indices = idx1:end_idx;
        scr = signal(range_indices);
      

        % Interpolation
        xx = linspace(idx1, end_idx, 2000); 
    

        %  Skip segments with only one value
        if length(scr) == 1
            start_idx = end_idx + 1;  % Move to next segment
            continue;                 % Skip interpolation and AUC calculation
        end
        yy = spline(range_indices, scr, xx); % Get y values for the above xx
        

        % yline(thr, '--r', 'LineWidth', 2);
        hold on

        % Process segments for AUC calculation
        area_start_idx = 1;

        while area_start_idx <= length(yy)
            % Find idxAUC1
            idxAUC1 = find(yy(area_start_idx:end) >= thr, 1, 'first');

            if isempty(idxAUC1)
                break;  % Exit loop if no more crossings above threshold
            end

            idxAUC1 = idxAUC1 + area_start_idx - 1;  % Adjust index relative to yy

            % Find idxAUC2
            idxAUC2 = find(yy(idxAUC1:end) < thr, 1, 'first');

            if isempty(idxAUC2)
                idxAUC2 = length(yy);  % If no idxAUC2 found, use end of yy
            else
                idxAUC2 = idxAUC2 + idxAUC1 - 1;  % Adjust index relative to yy
            end

            % Extract area and plot markers
            xarea = xx(idxAUC1:idxAUC2);
            yarea = yy(idxAUC1:idxAUC2);

            plot(xarea(1), yarea(1), 'og', 'MarkerSize', 5, 'MarkerFaceColor', 'g');  % Mark start point
            plot(xarea(end), yarea(end), 'or', 'MarkerSize', 5, 'MarkerFaceColor', 'r');  % Mark end point

            % Shade the area under the curve
            y2 = ones(size(xarea)) * thr;  % Y-line values (threshold)
            fill([xarea, fliplr(xarea)], [y2, fliplr(yarea)], 'g', 'EdgeColor', 'none', 'FaceAlpha', 0.2);

           

            % Calculate AUC for the shaded area
            AUC = trapz(xarea, yarea);
            auc_list = [auc_list, AUC];  % Store AUC in the list

            % Update area_start_idx for next segment
            area_start_idx = idxAUC2 + 1;
        end

        % Update start index for next segment
        start_idx = end_idx + 1;
    end

    sum_auc = sum(auc_list);  % Sum of all calculated AUCs

    num_seconds = 5;  % Number of seconds represented in the data
    xtick_positions = linspace(1, length(signal), num_seconds + 1);
    xtick_positions = unique(xtick_positions);  % ensure strictly increasing

    if numel(xtick_positions) > 1
        xticks(xtick_positions);
        xticklabels(arrayfun(@num2str, 0:length(xtick_positions)-1, 'UniformOutput', false));
    end

    set(gca, 'TickDir', 'out');
    

   
end
