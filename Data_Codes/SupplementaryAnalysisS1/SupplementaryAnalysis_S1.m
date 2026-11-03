%% Analysis S1: Compare mean absolute deviation b/w repository & primary data
% -------------------------------------------------------------------------
% This script reproduces statistical Supplementary Analysis S1 from the manuscript and completes:
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - file: 'SupplementaryS1.mat'in current directory
%
%
% OUTPUT:
%   - Statistical Analysis replicating Supplementary Analysis S1
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 3 Nov 2026
% MANUSCRIPT: 
% -------------------------------------------------------------------------


clearvars
clc

%% -----------------LOAD DATA---------------------------------

load SupplementaryAnalysis_S1.mat

%% -----------------CHECK NORMALITY---------------------------------

[h1,p1] = lillietest(repository_data);
[h2,p2] = lillietest(primary_data);

%% -----------------STATISTICAL ANLAYSIS---------------------------------

% Independent t-test
[h,p,ci, stats] = ttest2(repository_data, primary_data)


% compute effect-size 
std_primary = std(primary_data);
std_repository = std(repository_data);


pooled_sd = sqrt((std_primary^2 + std_repository^2)/2);

mean_diff = mean(repository_data) - mean(primary_data);

effect_size = mean_diff / pooled_sd