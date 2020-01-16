function [results] = spotAnalyzer2(spot_classProbsStack, CC, spotSpecificity, spotSizeMin, spotSizeMax)
%spotAnalyzer polishes detected spots

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
% cs10dec2019
%


stackSize = size(spot_classProbsStack);


% Pre-filter by voxel number (min/max spot size)!
CC_ = struct('Connectivity', [], 'ImageSize', [], 'NumObjects', [], 'PixelIdxList', {});
i_ = 0;
for i = 1:CC.NumObjects
    PixelIdxList = CC.PixelIdxList{i}(ge(spot_classProbsStack(CC.PixelIdxList{i}), spotSpecificity));
    % if ge(numel(PixelIdxList), 6)
    if ge(numel(PixelIdxList), prod(spotSizeMin)) && le(numel(PixelIdxList), prod(spotSizeMax))
        i_ = i_ + 1;
        CC_(1).PixelIdxList{i_} = PixelIdxList;
    end    
end
CC_(1).Connectivity = CC.Connectivity;
CC_.ImageSize = CC.ImageSize;
CC_.NumObjects = i_;
% 'PrincipalAxisLength'	Length (in voxels) of the major axes of the ellipsoid that have the same normalized
% second central moments as the region, returned as 1-by-3 vector. regionprops3 sorts the values from highest to lowest.
% stats = regionprops3(CC_, spot_classProbsStack, 'Centroid', 'PrincipalAxisLength', 'Orientation', 'weightedCentroid', 'EigenValues', 'EigenVectors', 'Volume', 'MeanIntensity', 'BoundingBox');
stats = regionprops3(CC_, spot_classProbsStack, 'Centroid', 'PrincipalAxisLength', 'Orientation', 'Volume', 'BoundingBox');

% Create result variable!
results = struct('spot_id', [], 'spot_center', [], 'spot_diameters_ellipsoid', [], 'BoundingBox', [], 'orientation', [], 'spotN', [], 'VoxelIdxList', []);
for i = 1:height(stats)
    results(i).spot_center = stats{i, 'Centroid'}([2,1,3]);
    results(i).spot_diameters_ellipsoid = stats{i, 'PrincipalAxisLength'};
    results(i).orientation = stats{i, 'Orientation'};
    results(i).BoundingBox = stats{i, 'BoundingBox'}(4:6); % Keep only width of bounding box
    results(i).spotN = stats{i, 'Volume'};
    results(i).VoxelIdxList = CC_.PixelIdxList{i};
end

% Clean data!
% Check for emtpy rows!
emptyRows = arrayfun(@(x) all(~isempty(results(x).spot_center(:))), 1:length(results));
results = results(emptyRows);

% Check for valid spot center position
validCenterIds = zeros(length(results),3);
for i = 1:3
    validCenterIds(:,i) = arrayfun(@(x) (gt(results(x).spot_center(:,i), 0) & le(results(x).spot_center(:,i), stackSize(i))), 1:length(results));
end
results = results(all(validCenterIds,2));

% Check for real ellipse axes!
realResults = arrayfun(@(x) isreal(results(x).spot_diameters_ellipsoid), 1:length(results));
results = results(realResults);

% Filter by spot minimum size!
validMinSizeIDs = zeros(length(results),3);
for i = 1:3
    validMinSizeIDs(:,i) = arrayfun(@(x) ge(results(x).BoundingBox(i), spotSizeMin(i)), 1:length(results));
end
results = results(all(validMinSizeIDs,2));

% Filter by spot maximum size!
validMaxSizeIDs = zeros(length(results),3);
for i = 1:3
    validMaxSizeIDs(:,i) = arrayfun(@(x) le(results(x).BoundingBox(i), spotSizeMax(i)), 1:length(results));
end
results = results(all(validMaxSizeIDs,2));

% Create spot id from final result list!
for i = 1:length(results)
    results(i).spot_id = i;
end

return

