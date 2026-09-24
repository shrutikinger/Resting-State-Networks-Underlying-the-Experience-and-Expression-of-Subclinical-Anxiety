%% FIGURE 2B: RT plot
% -------------------------------------------------------------------------
% This script reproduces Figure 2B from the manuscript and completes:
%   - Condition-specific visualization 
%   - Statistical comparison between the conditions 
%   - Figure export (300 dpi)
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - Statistics and Machine Learning Toolbox 
%   - Excel: 'data.xlsx' in current directory%
% OUTPUT:
%   - Figure replicating Figure 2B
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 24 September 2026
% MANUSCRIPT: 
% -------------------------------------------------------------------------

clearvars
clc

%% --------------------------- LOAD DATA ----------------------------------
file = readtable("data.xlsx");


UT = file.RT_UT;
US = file.RT_US;
CT = file.RT_CT;
CS = file.RT_CS;
all_data = [UT US CT CS];

%% --------------------------- FIGURE SETUP -------------------------------
mean_UT = mean(UT, 'omitnan');
mean_CT = mean(CT, 'omitnan');
mean_US = mean(US, 'omitnan');
mean_CS = mean(CS, 'omitnan');

N = 47; % Number of participants
sem_UT = std(UT, 'omitnan') / sqrt(N);
sem_CT = std(CT, 'omitnan') / sqrt(N);
sem_US = std(US, 'omitnan') / sqrt(N);
sem_CS = std(CS, 'omitnan') / sqrt(N);

% Organize data for plotting
% Rows = Factor A (Uncertainty, Certainty)
% Columns = Factor B (Threat, Safety)
plot_means = [mean_UT, mean_US; 
              mean_CT, mean_CS];

plot_sems  = [sem_UT,  sem_US; 
              sem_CT,  sem_CS];

% Create the Interaction Plot
figure('Color', 'w');
hold on;

x = [1, 2]; 

errorbar(x, plot_means(:,1), plot_sems(:,1), '-o', 'LineWidth', 2, ...
    'MarkerSize', 8, 'MarkerFaceColor', '#D95319', 'Color', '#D95319', 'DisplayName', 'Threat');

errorbar(x, plot_means(:,2), plot_sems(:,2), '-s', 'LineWidth', 2, ...
    'MarkerSize', 8, 'MarkerFaceColor', '#0072BD', 'Color', '#0072BD', 'DisplayName', 'Safety');

set(gca, 'XLim', [0.5, 2.5], 'XTick', x, 'XTickLabel', {'Uncertainty', 'Certainty'}, 'FontSize', 12);
xlabel('Factor A (Information State)', 'FontSize', 13);
ylabel('Reaction Time (z-score)', 'FontSize', 13);
ax= gca;
ax.LineWidth = 1.5;
ax.TickDir ='out'

legend('Location', 'northeast');

hold off;
% find outliers
conditions = {UT, CT, US, CS};
names = {'UT', 'CT', 'US', 'CS'};

%% Outlier detection

% Create a logical matrix to track outliers 
outlier_mask = false(size(all_data));

fprintf('--- Outlier Analysis (1.5 x IQR Rule) ---\n\n');

for i = 1:4
    data_col = conditions{i};
    
    
    q1 = prctile(data_col, 25);
    q3 = prctile(data_col, 75);
    iqr_val = q3 - q1;
    
  
    lower_bound = q1 - 3 * iqr_val;
    upper_bound = q3 + 3 * iqr_val;
    
    
    is_outlier = (data_col < lower_bound) | (data_col > upper_bound);
    outlier_mask(:, i) = is_outlier;
    
   
    outlier_indices = find(is_outlier);
    num_outliers = length(outlier_indices);
    
    fprintf('Condition %s:\n', names{i});
    fprintf('  Bounds: [%.4f, %.4f] (IQR = %.4f)\n', lower_bound, upper_bound, iqr_val);
    if num_outliers > 0
        fprintf('  Found %d outlier(s) at Subject row(s): %s\n', ...
            num_outliers, num2str(outlier_indices'));
        fprintf('  Outlier values: %s\n', num2str(data_col(is_outlier)'));
    else
        fprintf('  No outliers found.\n');
    end
    fprintf('\n');
end

 
%% ===================== STATISTICAL ANALYSIS -----------------------------

t = table(UT, CT, US, CS);
% Define the within-subject factors 
factor_A = categorical({'Uncertainty'; 'Certainty'; 'Uncertainty'; 'Certainty'});
factor_B = categorical({'Threat'; 'Threat'; 'Safety'; 'Safety'});

% Create within-design table
within_design = table(factor_A, factor_B, 'VariableNames', {'factorA', 'factorB'});

% Fit the repeated measures model
rm = fitrm(t, 'UT-CS~1', 'WithinDesign', within_design);

%Run the repeated measures ANOVA 
tbl = ranova(rm, 'WithinModel', 'factorA*factorB')


%check normlaity of residuals
Y_actual = t{:, {'UT', 'CT', 'US', 'CS'}};

% Get the model's predicted values
% 'predict' expects the model and the original table
Y_predicted = predict(rm, t);

% Calculate the residuals (Observed - Predicted)
resids = Y_actual - Y_predicted;

flat_resids = resids(:);

% Run the Lilliefors test to check for normality
[h, p, kstat, critval] = lillietest(flat_resids)



%% ===================== SAVE FIGURE (300 DPI) ============================

exportgraphics(gca, 'Figure2B.tiff','Resolution',300)