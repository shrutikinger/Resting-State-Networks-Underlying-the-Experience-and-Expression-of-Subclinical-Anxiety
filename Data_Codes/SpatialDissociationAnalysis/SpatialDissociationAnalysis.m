%% Spatial Dissociation Analysis
% -------------------------------------------------------------------------
% This script reproduces spatial dissociation analysis from the manuscript and computes:
%   - Eucledian distance
%
%
% REQUIREMENTS:
%   - MATLAB (R2021a or later)
%   - Statistics and Machine Learning Toolbox, SPM 
%   - .nii files in current directory%
% OUTPUT:
%   - Eucledian distance b/w Microsystem A and B, B and C, and A and C
%
% AUTHOR: Shruti Kinger <shrutik@iiitd.ac.in>
% DATE: 24 September 2026
% MANUSCRIPT: 
% -------------------------------------------------------------------------


clearvars
clc
niiFiles = {
    'systemA_ICA26.nii'
    'systemB_ICA5.nii'
    'systemC_ICA2.nii'
};

numFiles = numel(niiFiles);

centroids_voxel = zeros(numFiles,3);
centroids_mm = zeros(numFiles,3);

for i = 1:numFiles

    info = niftiinfo(niiFiles{i});
    V = double(niftiread(info));

    mask = V > 0;

    [x,y,z] = ind2sub(size(V), find(mask));

    weights = V(mask);

    % Weighted centroid in voxel coordinates
    Cx = sum(x.*weights)/sum(weights);
    Cy = sum(y.*weights)/sum(weights);
    Cz = sum(z.*weights)/sum(weights);

    centroids_voxel(i,:) = [Cx Cy Cz];

    % Convert to mm coordinates
    T = info.Transform.T';

    world = (T * [Cx Cy Cz 1]')';

    centroids_mm(i,:) = world(1:3);

end

disp('Weighted centroid (voxels)')
disp(centroids_voxel)

disp('Weighted centroid (mm)')
disp(centroids_mm)


D12 = norm(centroids_mm(1,:) - centroids_mm(2,:));
D13 = norm(centroids_mm(1,:) - centroids_mm(3,:));
D23 = norm(centroids_mm(2,:) - centroids_mm(3,:));

fprintf('\nDistances (mm)\n');
fprintf('MicrosystemA - MicrosystemB = %.2f mm\n', D12);
fprintf('MicrosystemA - MicrosystemC = %.2f mm\n', D13);
fprintf('MicrosystemB - MicrosystemC = %.2f mm\n', D23);