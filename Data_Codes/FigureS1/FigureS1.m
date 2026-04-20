%% FIGURE S1: Sample plot of of AUC of one participant for one participant in a single session, including all trials across the four conditions.
% -------------------------------------------------------------------------
% This script reproduces Figure S1 from the manuscript and completes:
%   - Condition-specific visualization
%   - Figure export (300 dpi)
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - .mat file: 'AUC_data.mat' in current directory
%   - function: calculateAUC.m in current directory
%
%
% OUTPUT:
%   - Figure replicating Figure S1
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 20 April 2026
% MANUSCRIPT:
% -------------------------------------------------------------------------

clearvars;
close all;
clc;

%% --------------------------LOAD DATA-------------------------------------
load FigureS1.mat
conditions = {UT_baseline_correction, US_baseline_correction, ...
    CT_baseline_correction, CS_baseline_correction};


%% --------------------------- FIGURE SETUP -------------------------------
titles = {'UT','US','CT','CS'};
thr = 0.01;
figure;
set(gcf,'Position',[0 0 1200 1200])

for i = 1:8
    for c = 1:4

        idx = (c-1)*8 + i;
        subplot(4, 8, idx);
        hold on

        if ~isempty(conditions{c}{i})

            signal = conditions{c}{i};
            calculateAUC(signal, thr);

        else
            % ---- Blank plot ----
            plot(nan, nan);

            num_seconds = 5;
            xlim([0 num_seconds])
            xticks(0:num_seconds)
            ylim([0 1]);
        end

        title([titles{c} ' - ' num2str(i)]);
        set(gca,'TickDir','out');

        % Y label only for first column
        if i == 1
            ylabel('SCR-corrected','FontSize',14)
        end

        % X label only for last row
        if idx >= 25 && idx <= 32
            xlabel('Time (s)','FontSize',14)
        end

    end
end


%% ===================== SAVE FIGURE (300 DPI) ============================
output_name = 'FigureS1';

% Save as PNG (300 dpi)
print(gcf, [output_name '.png'], '-dpng', '-r300');

% Save as TIFF (300 dpi)
print(gcf, [output_name '.tif'], '-dtiff', '-r300');