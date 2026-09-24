%% FIGURE S3: Correlation between anxiety scores and Reaction Time
% -------------------------------------------------------------------------
% This script reproduces Figure S3 from the manuscript and completes:
%   - Condition-specific visualization of mean SCR
%   - Figure export (300 dpi)
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - function: shadedErrorBar.mat in current directory 
%   - file: 'MenaSCR.mat' in current directory
%
%
% OUTPUT:
%   - Figure replicating Figure S3
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 20 April 2026
% MANUSCRIPT: 
% -------------------------------------------------------------------------


clear
clc
load FigureS3.mat

% extract baseline timeline
baseline_condUT = condUT(:,21:30); 
baseline_condUS = condUS(:,21:30);
baseline_condCT = condCT(:,21:30);
baseline_condCS = condCS(:,21:30);

conds = {condUT, condUS, condCT, condCS};
condNames = {'Uncertain Threat','Uncertain Safety','Certain Threat','Certain Safety'};
all_basl = {baseline_condUT, baseline_condUS, baseline_condCT, baseline_condCS};

figure
set(gcf,'Position',[10 10 600 600])
x=linspace(0,6,60)
for i = 1:4
    subplot(2,2,i)

    
 
    baseline =(mean(all_basl{i},2));      % participant baseline

    data = (conds{i} - baseline );          % subtract baseline from each participant
    

    meanTrace = mean(data(:,21:80),1);   % mean across participants
    N = size(data,1);
    sem = std(data(:,21:80),0,1) ./ sqrt(size(data,1));   % SEM at each time point

    
     % 95% confidence interval
    t_critical = tinv(0.975,N-1);
    CI95 = t_critical .* sem;

    % Mean + 95% CI shaded patch
    shadedErrorBar(x,meanTrace,CI95,'lineProps','b');

    title(condNames{i},'FontSize',12)
   
   
    if i==1 || i==3
        ylabel('SCR (baseline-corrected)','FontSize',10)
    end
    if i==3 || i==4
        xlabel('Time(s)','FontSize',10)
    end
    xline(1,'g','LineWidth',2,'LineStyle','--')
    
    box off
    ax=gca;
    ax.LineWidth = 1.5;
    
    
end

exportgraphics(gcf,'FigureS3.tif','Resolution',300)

