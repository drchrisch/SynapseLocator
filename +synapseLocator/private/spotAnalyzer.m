function [results] = spotAnalyzer(data, spotSizeMin, spotSizeMax, bwconncompValue)
%spotAnalyzer polishes detected spots

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%


data_tmp = data;

data_tmp = bwconncomp(data_tmp, bwconncompValue); % Allowed values for 3D bwconncomp: 6, 18, 26!!!


% Create result variable!
results = struct('spot_id', [], 'spot_center', [], 'spot_diameters_ellipsoid', [], 'spotN', [], 'VoxelIdxList', []);

% Turn off/on annoying message from ellipsoid fit!
msgid_integerCat = 'MATLAB:nearlySingularMatrix';
warning('off', msgid_integerCat);

for i = 1:data_tmp.NumObjects
    if ge(length(data_tmp.PixelIdxList{i}), 9) % Look for spots with minimal number of 9 voxels (required for ellipsoid fit)!
        [Ix,Iy,Iz] = ind2sub(size(data), data_tmp.PixelIdxList{i});
        if ge(size(unique([Ix,Iy,Iz], 'rows'), 1), 9) && all([gt(length(unique(Ix)),1), gt(length(unique(Iy)),1), gt(length(unique(Iz)),1)])
            % Get cell dimensions from ellipsoid fit!
            % Note that function flag '' calculates ellipsoid radii along ellipsoid axis and describes
            % the shape of the ellipsoid! Function flag '0' reports the radii projected onto the coordinate
            % system!
            % 'True' ellipsoid radius!
            [center, radii, ~, ~, ~ ] = ellipsoid_fit_new([Ix Iy Iz]);
            % Get diameter from radii, seems more appropriate for spot size description!
            diameters_ellipsoid = radii' * 2;
            
            results(i).spot_center = center';
            results(i).spot_diameters_ellipsoid = diameters_ellipsoid;
            results(i).spotN = sum(data(data_tmp.PixelIdxList{i}));
            results(i).VoxelIdxList = data_tmp.PixelIdxList{i};
        end
    end
end
warning('on', msgid_integerCat);
clear data_tmp

% Clean data!
% Check for emtpy rows!
emptyRows = arrayfun(@(x) all(~isempty(results(x).spot_center(:))), 1:length(results));
results = results(emptyRows);

% Check for correct boundary)
expectedPos = size(data);
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

