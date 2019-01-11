function [results] = spotAnalyzer2(spot_classProbsStack, CC, spotSpecificity, spotSizeMin, spotSizeMax)
%spotAnalyzer polishes detected spots

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%


stackSize = size(spot_classProbsStack);


CC_ = struct('Connectivity', [], 'ImageSize', [], 'NumObjects', [], 'PixelIdxList', {});
i_ = 0;
for i = 1:CC.NumObjects
    PixelIdxList = CC.PixelIdxList{i}(ge(spot_classProbsStack(CC.PixelIdxList{i}), spotSpecificity));
    if ge(numel(PixelIdxList), 6)
        i_ = i_ + 1;
        CC_(1).PixelIdxList{i_} = PixelIdxList;
    end    
end
CC_(1).Connectivity = CC.Connectivity;
CC_.ImageSize = CC.ImageSize;
CC_.NumObjects = i_;

stats = regionprops3(CC_, spot_classProbsStack, 'Centroid', 'PrincipalAxisLength', 'Orientation', 'weightedCentroid', 'EigenValues', 'EigenVectors', 'Volume', 'MeanIntensity');


% Create result variable!
results = struct('spot_id', [], 'spot_center', [], 'spot_diameters_ellipsoid', [], 'spotN', [], 'VoxelIdxList', []);
for i = 1:height(stats)
    results(i).spot_center = stats{i,'Centroid'}([2,1,3]);
    results(i).spot_diameters_ellipsoid = stats{i,'PrincipalAxisLength'};
    results(i).spotN = stats{i,'Volume'};
    results(i).VoxelIdxList = CC_.PixelIdxList{i};
end


% Clean data!
% Check for emtpy rows!
emptyRows = arrayfun(@(x) all(~isempty(results(x).spot_center(:))), 1:length(results));
results = results(emptyRows);

% Check for correct boundary)
expectedPos = stackSize;
correctPosIds = zeros(length(results),3);
for i = 1:3
    correctPosIds(:,i) = arrayfun(@(x) (gt(results(x).spot_center(:,i), 0) & le(results(x).spot_center(:,i), expectedPos(i))), 1:length(results));
end
correctPosIds = all(correctPosIds,2);
results = results(correctPosIds);

% Check for real ellipse axes!
realResults = arrayfun(@(x) isreal(results(x).spot_diameters_ellipsoid), 1:length(results));
results = results(realResults);

% Filter by spot intensity
intensityTreshold = 9;
intensityIds = arrayfun(@(x) ge(results(x).spotN, intensityTreshold), 1:length(results));
results = results(intensityIds);

% Filter by spot minimum diameter!
expectedDiameterMin = spotSizeMin; % default values should be [2, 2, 2], but..........
expectedDiameterMinIds = zeros(length(results),3);
for i = 1:3
    expectedDiameterMinIds(:,i) = arrayfun(@(x) ge(results(x).spot_diameters_ellipsoid(i), expectedDiameterMin(i)), 1:length(results));
end
expectedDiameterMinIds = all(expectedDiameterMinIds,2);
results = results(expectedDiameterMinIds);

% Filter by spot maximum diameter! Use diameter in xyz-projection!
expectedDiameterMax = spotSizeMax; % default: [25, 25, 15]
expectedDiameterMaxIds = zeros(length(results),3);
for i = 1:3
    expectedDiameterMaxIds(:,i) = arrayfun(@(x) le(results(x).spot_diameters_ellipsoid(i), expectedDiameterMax(i)), 1:length(results));
end
expectedDiameterMaxIds = all(expectedDiameterMaxIds,2);
results = results(expectedDiameterMaxIds);

% Create spot id from final result list!
for i = 1:length(results)
    results(i).spot_id = i;
end

return

