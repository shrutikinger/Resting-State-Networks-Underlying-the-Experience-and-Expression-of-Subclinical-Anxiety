%% FIGURE 3: Correlation matrix (3B) and ring connectome (3C)
% -------------------------------------------------------------------------
% This script reproduces Figure 3B and 3C from the manuscript and completes:
%   - visualization 
%   - Figure export (300 dpi)
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - Excel: 'ROIs.xlsx' & julich_brain_map.xlsx in current directory
%   - functions: circosChart.m, cleanRegionName.m, getRegionName.m,
%                hideClassLabels.m, brewermap.m
%
%
% OUTPUT:
%   - Figure replicating Figure 3B and 3C
%   
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 20 April 2026
% MANUSCRIPT: 
% -------------------------------------------------------------------------

clearvars;
close all;
clc;

%% --------------------------- LOAD DATA ----------------------------------
file = readtable("ROIs.xlsx",Sheet="RT_UTxanxiety");
source = file.SourceFile;   
target = file.Targets;      
tvalue = file.T_40_;
df = 47-2;
rValue = tvalue ./ sqrt(tvalue.^2 + df);

source_name = cell(size(source));
target_name = cell(size(target));

% Read mapping file (julich_brain.xlsx)
mapData = readtable("julich_brain_map.xlsx", 'FileType', 'spreadsheet', ...
                    'ReadVariableNames', true);

%%-----------
for i = 1:numel(source)
    source_name{i} = getRegionName(source{i}, mapData);
    target_name{i} = getRegionName(target{i}, mapData);
end
source_name = cellfun(@cleanRegionName, source_name, 'UniformOutput', false);
target_name = cellfun(@cleanRegionName, target_name, 'UniformOutput', false);


file.SourceName = source_name;
file.TargetName = target_name;


%% -----------------CREATE CORRELATION MATRIX------------------------------------------
% Combine into a cell array: {source, target, r}
data = [source_name, target_name, num2cell(rValue)];

% Get all unique node labels
allNodes = unique([source_name; target_name]);
n = length(allNodes);

% Map labels to matrix indices
labelMap = containers.Map(allNodes, 1:n);

% Initialize matrices
corrMatrix = zeros(n);     % Weighted correlation values
adjBinary = zeros(n);      % Binary adjacency (for structure)

% Fill matrices
for i = 1:size(data,1)
    src = data{i,1};
    tgt = data{i,2};
    tval = data{i,3};

    row = labelMap(src);
    col = labelMap(tgt);

    corrMatrix(row, col) = tval;
    corrMatrix(col, row) = tval;       % Make symmetric

  

    adjBinary(row, col) = 1;
    adjBinary(col, row) = 1;
end



 %% -------------------PLOT CORRELATION MATRIX-----------------------------------------
close all

%  Desired cell size (in pixels)
cellSize = 60;  

% Matrix size
n = size(corrMatrix,1);

% Set figure size based on cells
figWidth  = cellSize * n;
figHeight = cellSize * n;


set(gcf, 'Position', [0 0 figWidth figHeight]);

mask = triu(true(size(corrMatrix)), 1); % upper triangle, excluding diagonal

corrMatrix(mask) = NaN; % set upper triangle to NaN
for i = 1:size(corrMatrix,1)
    corrMatrix(i,i) = 5;
end

% plot matrix
imagesc(corrMatrix, 'AlphaData', ~isnan(corrMatrix));  % NaNs transparent
hold on

for i = 1:n
    for j = 1:n
        if j <= i   % only lower triangle (including diagonal)
            rectangle('Position',[j-0.5, i-0.5, 1, 1], ...
                      'EdgeColor','k','LineWidth',1); % black outline
        end
    end
end
set(gca, 'Tickdir', 'out')
set(gca,'Color','none'); 
hold off
cmap = flipud(colormap(brewermap(100,'PuOr')))
nanColor = [0.96 0.96 0.86];

% nanColor = [0.8 0.8 0.8];
cmap(45:55,:) = repmat(nanColor,11,1);  % replace middle with light gray   
colormap(cmap);
colorbar;


axis equal tight
caxis([-1 1]);             % Pearson r range
cb = colorbar;
cb.Label.FontSize = 12;         
cb.Label.FontWeight = 'bold';   
cb.Label.Rotation = 0;          
cb.Label.HorizontalAlignment = 'center';

% Position adjustments
pos = cb.Label.Position;         % current [x y z]
pos(1) = pos(1) - 0.4;              % move left
pos(2) = pos(2) + 5.9;              % move up
cb.Label.Position = pos;

xticks(1:length(allNodes));
yticks(1:length(allNodes));
xticklabels(allNodes);
yticklabels(allNodes);
xtickangle(90);

box off;  
hold off


%% ===================== SAVE FIGURE (300 DPI) ============================
output_name = 'Figure3B';

% Save as PNG (300 dpi)
print(gcf, [output_name '.png'], '-dpng', '-r300');

% Save as TIFF (300 dpi)
print(gcf, [output_name '.tif'], '-dtiff', '-r300');

%% ------------------------------RING CONNECTOME -------------------------------

Class = 1:n;
CC = circosChart(adjBinary, Class);

CC = CC.draw();
CC.hideClassLabels();

all_rs =[];
n = size(corrMatrix,1);

colors=[];
edgecolor= [0 0 0]
for i = 1:n
    for j = i+1:n  % upper triangle only (above diagonal)
        t_val = corrMatrix(i,j);
        all_rs = [all_rs rValue];
        
    end

end

colors = flipud(brewermap(n, 'OrRd'));
CC.setColor(1:n, colors);
theta = linspace(0, 4*pi, 1000); % Circle resolution
r = 1.02; 
xRing = r * cos(theta);
yRing = r * sin(theta);
colour = [0.7 0.7 0.7];
plot(xRing, yRing, 'Color', colour, 'LineWidth', 2); 
axis equal;

% Set labels
for i = 1:n
    set(CC.partLabelHdl(i), 'String', allNodes{i}, 'FontSize', 10, 'Color', 'k');
end

% Get min and max from absolute r-values
weights = abs(corrMatrix(corrMatrix ~= 0)); % exclude zero
minW = min(weights);
maxW = max(weights);


% Choose scaling range for line widths
minLW =2; 
maxLW = 5;
all_t =[];
black = [1 0 0];
all_edgeColors = [];
% Loop through all possible edges
for i = 1:size(CC.lineHdl,1)
    for j = 1:size(CC.lineHdl,2)
        if CC.lineHdl(i,j) ~= 0 && isgraphics(CC.lineHdl(i,j))
            t_val = corrMatrix(i,j);
            all_t = [all_t ;t_val];

           
            % Map r/t value to line width
            lineW = minLW + (abs(t_val) - minW) * (maxLW - minLW) / (maxW - minW);

             % Decide color based on sign
            if t_val < 0
                edgeColor = [0 0 1];   % blue for negative
                lineStyle = '-.';      % dashed
            else
                edgeColor = [1 0 0];   % red for positive
                lineStyle = '-';       % solid
            end

            set(CC.lineHdl(i,j), 'LineWidth', lineW,...
                                 'Color', edgeColor, ...
                                 'LineStyle', lineStyle);
          


        end
    end
end

%% ===================== SAVE FIGURE (300 DPI) ============================
output_name = 'Figure3C';

% Save as PNG (300 dpi)
print(gcf, [output_name '.png'], '-dpng', '-r300');

% Save as TIFF (300 dpi)
print(gcf, [output_name '.tif'], '-dtiff', '-r300');

