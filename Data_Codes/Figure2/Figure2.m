%% FIGURE 2: Correlation between anxiety scores and Reaction Time
% -------------------------------------------------------------------------
% This script reproduces Figure 2 from the manuscript and completes:
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
%   - Figure replicating Figure 2
%   - Statistical results 
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 20 April 2026
% MANUSCRIPT: Intrinsic Brain Networks Underlying the Experience and Expression of Subclinical Anxiety
% -------------------------------------------------------------------------

clearvars;
close all;
clc;

%% --------------------------- LOAD DATA ----------------------------------
data = readtable("data.xlsx");


%% ------------------------z score of data---------------------------
rt_UT = zscore(data.RT_UT);
rt_US = zscore(data.RT_US);
rt_CT = zscore(data.RT_CT);
rt_CS = zscore(data.RT_CS);

fearAffect = zscore(data.FearAffect);

%% --------------------------- FIGURE SETUP -------------------------------


figure
set(gcf, 'Position', [50, 50, 800, 800])
jitterAmountX = 0.002;  
jitterAmountY = 0.002; 

RTs = {rt_UT, rt_US, rt_CT, rt_CS};


t = tiledlayout(2,2,'Padding','compact','TileSpacing','compact')

ax_all = gobjects(1,4);


for i = 1:4
    nexttile
    hold on

    rt = RTs{i};

    
    xj = fearAffect + (rand(size(fearAffect)) - 0.5) * jitterAmountX;
    yj = rt + (rand(size(rt)) - 0.5) * jitterAmountY;

    scatter(xj, yj, ...
        'MarkerFaceColor', [0 0.4470 0.7410], ...
        'MarkerEdgeColor', [0 0.4470 0.7410], ...
        'MarkerFaceAlpha', 0.3, ...
        'MarkerEdgeAlpha', 1, ...
        'LineWidth', 1.5, ...
        'SizeData', 200);

    % fit regression model
    mdl = fitlm(fearAffect, rt);
    
    x_vals = linspace(-3, 3, 100);
    y_vals = predict(mdl, x_vals');

    %---- scatter: x: anxiety scores ; y: RT z-scores------------------
    plot(x_vals, y_vals, ...
        'Color', [0 0.4470 0.7410], ...
        'LineWidth', 3);
    
  
    
    

    %% AXIS FORMATTING
    if i == 1 || i==3
        ylabel('Reaction Time (z-scores)')
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
h_norm_RT = zeros(1,4);
p_norm_RT = zeros(1,4);


for norm = 1:4

    [h_norm_RT, p_norm_RT] = lillietest(RTs{norm});

    fprintf('Lilliefors test for normality: p = %.5f\n', p_norm_RT);

    if h_norm_RT == 0
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
%% 2. Outlier detection (z-score METHOD)

all_vars = [rt_UT rt_US rt_CT rt_CS fearAffect];

% Identify outliers using z-score method
z_scores = abs(zscore(all_vars));
outliers = any(z_scores > 3, 2); % flagging outliers

if any(outliers)==1
    fprintf('Outlier indices: ');
    disp(find(outliers)');
else
    fprintf('No significant outliers detected\n');
end

%% ===================== STATISTICAL ANALYSIS -----------------------------
r_vals = zeros(1,4);
p_vals = zeros(1,4);
ci_vals = zeros(2,4); % lower & upper bounds


for k = 1:4

    rt = RTs{k};

    [r, p] = corr(fearAffect, rt);

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
output_name = 'Figure2B';

% Save as PNG (300 dpi)
print(gcf, [output_name '.png'], '-dpng', '-r300');

% Save as TIFF (300 dpi)
print(gcf, [output_name '.tif'], '-dtiff', '-r300');
