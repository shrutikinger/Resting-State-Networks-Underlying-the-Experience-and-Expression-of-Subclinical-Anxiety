%% FIGURE S3: Correlation matrix - UT, US, CT, UTSBI
% -------------------------------------------------------------------------
% This script reproduces Figure S3 from the manuscript and completes:
%   - Correlation matrix b/w UT, US, CT, UTSBI
%   - Figure export (300 dpi)
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - file: 'UTSBI.mat' & data.xlsx in current directory
%
%
% OUTPUT:
%   - Figure replicating Figure S3
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 3 Nov 2026
% MANUSCRIPT: 
% -------------------------------------------------------------------------

clearvars
clc

%% -----------------LOAD DATA---------------------------------
load UTSBI.mat

all_data = readtable('data.xlsx');

pure_UT = UTSBI;

RT_UT = all_data.RT_UT;

RT_US = all_data.RT_US;

RT_CT = all_data.RT_CT;

%% -----------------STATISTICAL ANALYSIS---------------------------------

zscore_pureUT = zscore(pure_UT);

idx_outliers = find(abs(zscore_pureUT)>3);


all_vals = [RT_UT RT_CT RT_US pure_UT];

varNames = {'UT', 'CT', 'US', 'UTSBI'};

for val = 1:4
    [h,p] = lillietest(all_vals(:,val));
      fprintf('Lilliefors test for %s: h = %d, p = %.4f\n', ...
        varNames{val}, h, p);
end




%% ----------------- CORRELATION MATRIX---------------------------------

% Arrange variables in the desired order
X = [RT_UT(:), RT_CT(:), RT_US(:), pure_UT(:)];

varNames = {'UT', 'CT', 'US', 'UTSBI'};

% Calculate Spearman correlation and p-value matrices
[R, P] = corr(X, 'Type', 'Pearson', ...
                 'Rows', 'pairwise');

% Display numerical matrices
disp('Pearson correlation coefficients (rho):');
disp(array2table(R, 'VariableNames', varNames, ...
                    'RowNames', varNames));

disp('P-value matrix:');
disp(array2table(P, 'VariableNames', varNames, ...
                    'RowNames', varNames));


%% ----------------PLOT---------------------------------

figure('Color','w','Position',[300 200 600 400]);
% Mask upper triangle
R_lower = R;
R_lower(triu(true(size(R)),1)) = NaN;

% Plot lower triangle only
h = imagesc(R_lower);
set(h,'AlphaData',~isnan(R_lower));

clim([-1 1]);


n = 256;

blue  = [0.25 0.40 0.60];
white = [1.00 1.00 1.00];
orange = [0.85 0.58 0.36];

cmap = [ ...
    linspace(blue(1),white(1),n/2)', ...
    linspace(blue(2),white(2),n/2)', ...
    linspace(blue(3),white(3),n/2)'; ...
    linspace(white(1),orange(1),n/2)', ...
    linspace(white(2),orange(2),n/2)', ...
    linspace(white(3),orange(3),n/2)' ];


colormap(cmap);


axis square;
ax.Linewidth = 2;
xlim([0.5 4.5]);
ylim([0.5 4.5]);

set(gca,'YDir','reverse', ...
    'XTick',1:4,'YTick',1:4, ...
    'XTickLabel',varNames, ...
    'YTickLabel',varNames, ...
    'FontSize',12, ...
    'TickLength',[0 0], ...
    'Box','off');




% Add rho and p-values
for i = 1:4
    for j = 1:i

        if i == j
            label = sprintf('r = 1.00');
        else
            if P(i,j) < 0.001
                p_3decimalPlaces = 0.001
                label = sprintf('r = %.2f\np < %.3f',R(i,j),p_3decimalPlaces);
            else
                label = sprintf('r = %.2f\np = %.3f',R(i,j),P(i,j));
            end
        end

        text(j,i,label, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'FontSize',10, ...
            'Color',[0.20 0.20 0.20]);
    end
end

% Subtle borders only around lower triangle
hold on;
for i = 1:4
    for j = 1:i
        rectangle('Position',[j-0.5 i-0.5 1 1], ...
            'EdgeColor',[0.90 0.90 0.90], ...
            'LineWidth',0.7);
    end
end
hold off;
colormap(cmap);
cb = colorbar;
cb.Label.String = 'Pearson correlation (r)';
cb.FontSize = 10;
clim([-1 1]);


%% -----------------SAVE FIGURE---------------------------------
exportgraphics(gcf, 'FigureS3.tif', 'Resolution', 300);