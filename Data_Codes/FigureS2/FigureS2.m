%% FIGURE S2: Correlation between anxiety scores and Skin Conductance Response
% -------------------------------------------------------------------------
% This script reproduces Figure S2 from the manuscript and completes:
%   - Condition-specific visualization 
%   - Statistical comparison between the conditions 
%   - Figure export (300 dpi)
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - Statistics and Machine Learning Toolbox 
%   - Excel: 'data.xlsx' in current directory
%
%
% OUTPUT:
%   - Figure replicating Figure S2
%   - Statistical results 
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 20 April 2026
% MANUSCRIPT: 
% -------------------------------------------------------------------------

clearvars;
close all;
clc;

%% --------------------------- LOAD DATA ----------------------------------
data = readtable("data.xlsx");


%% ------------------------z score of data---------------------------
scr_UT = zscore(data.SCR_UT);
scr_US = zscore(data.SCR_US);
scr_CT = zscore(data.SCR_CT);
scr_CS = zscore(data.SCR_CS);

fearAffect = zscore(data.FearAffect);

%% --------------------------- FIGURE SETUP -------------------------------


figure
set(gcf, 'Position', [50, 50, 800, 800])
jitterAmountX = 0.002;  
jitterAmountY = 0.002; 

SCRs = {scr_UT, scr_US, scr_CT, scr_CS};


t = tiledlayout(2,2,'Padding','compact','TileSpacing','compact')

ax_all = gobjects(1,4);


for i = 1:4
    nexttile
    hold on

    scr = SCRs{i};

    
    xj = fearAffect + (rand(size(fearAffect)) - 0.5) * jitterAmountX;
    yj = scr + (rand(size(scr)) - 0.5) * jitterAmountY;

    scatter(xj, yj, ...
        'MarkerFaceColor', [0 0.4470 0.7410], ...
        'MarkerEdgeColor', [0 0.4470 0.7410], ...
        'MarkerFaceAlpha', 0.3, ...
        'MarkerEdgeAlpha', 1, ...
        'LineWidth', 1.5, ...
        'SizeData', 200);

  
    

    %% AXIS FORMATTING
    if i == 1 || i==3
        ylabel('SCR (z-scores)')
    end

    if i==3 || i==4
        xlabel('Anxiety (z-scores)')
    end

      % axes
    ax = gca;
    ax_all(i) = ax;
    ax.LineWidth = 2.5;
    ax.FontSize = 16;
    ax.TickDir = 'out';


    xlim([-3 3])
    ylim([-3 3])
    axis manual

end


box off





%% ===================== ASSUMPTION CHECKS FOR STATS ANALYSIS ================================

fprintf('\n--- ASSUMPTION CHECKS FOR STATS ANALYSIS ---\n');

%% 1. Normality (Lilliefors test on reaction time and anxiety scores)
h_norm_SCR = zeros(1,4);
p_norm_scr = zeros(1,4);


for norm = 1:4

    [h_norm_SCR, p_norm_scr] = lillietest(SCRs{norm});

    fprintf('Lilliefors test for normality: p = %.5f\n', p_norm_scr);

    if h_norm_SCR == 0
        fprintf('Normality assumption: NOT violated\n');
    else
        fprintf('Normality assumption: VIOLATED\n');
    end
end


[h_norm_anx, p_norm_anx] = lillietest(fearAffect); 

fprintf('Lilliefors test for normality: p = %.5f\n', p_norm_anx);

if h_norm_anx == 0
    fprintf('Normality assumption: NOT violated\n');
else
    fprintf('Normality assumption: VIOLATED\n');
end


%% 2. Outlier detection (IQR method)

for j =1:4
    Q1 = prctile(SCRs{i}, 25);
    Q3 = prctile(SCRs{i}, 75);
    IQR_val = Q3 - Q1;

    lower_bound = Q1 - 2 * IQR_val;
    upper_bound = Q3 + 2 * IQR_val;

    outliers = SCRs{i} < lower_bound | SCRs{i} > upper_bound;
    numOutliers = sum(outliers);

    fprintf('Outliers detected (IQR method): %d\n', numOutliers);

    if numOutliers > 0
        fprintf('Outlier indices: ');
        disp(find(outliers)');
    else
        fprintf('No significant outliers detected\n');
    end
end
%% ===================== STATISTICAL ANALYSIS -----------------------------
r_vals = zeros(1,4);
p_vals = zeros(1,4);
ci_vals = zeros(2,4); % lower & upper bounds


for k = 1:4

    scr = SCRs{k};

    [r, p] = corr(fearAffect, scr,"Type","Spearman");

    % Fisher z-transform for confidence interval
    n = length(fearAffect);
    z = atanh(r);
    se = 1 / sqrt(n - 3);

    z_crit = 1.96; % for 95% CI
    z_lower = z - z_crit * se;
    z_upper = z + z_crit * se;

    ci_lower = tanh(z_lower);
    ci_upper = tanh(z_upper);

    % store values
    r_vals(k) = r;
    p_vals(k) = p;
    ci_vals(:,k) = [ci_lower; ci_upper];
end

%% ===================== SAVE FIGURE (300 DPI) ============================
output_name = 'FigureS2';

% Save as PNG (300 dpi)
print(gcf, [output_name '.png'], '-dpng', '-r300');

% Save as TIFF (300 dpi)
print(gcf, [output_name '.tif'], '-dtiff', '-r300');