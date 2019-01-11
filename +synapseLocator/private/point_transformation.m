function results = point_transformation(sLobj, results)
% Transform points!

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')

sLobj.statusTextH.String = 'Calculating point transformation!';
drawnow


% Needed file should be present!
d = dir(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'TransformParameters*txt'));
transformParametersFile = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, d(end).name);

% Write points to file!
voxelN = arrayfun(@(x) numel(results(x).VoxelIdxList), 1:numel(results));
voxelIDs = cell2mat(arrayfun(@(x) (results(x).VoxelIdxList), 1:numel(results), 'Uni', 0)');
stackSize = sLobj.data.sizeStack2;
[X,Y,Z] = ind2sub(stackSize, voxelIDs);
writePointsFile(fullfile(sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder, 'FileWithPoints.txt'), [Y, X, Z], 'point')

% Build the the appropriate command!
transformixCall = sprintf('"%s\\%s\\%s"', sLobj.synapseLocatorFolder, sLobj.elastixFolder, 'transformix');

CMD = sprintf('%s -out "%s" -tp "%s"',...
    transformixCall,...
    fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir),...
    transformParametersFile);

priority = 'normal'; %'high'; % 'abovenormal' 'normal' 'belownormal'
CMD = sprintf('%s -priority %s', CMD, priority);

def = sprintf('"%s\\%s\\%s"', sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder, 'FileWithPoints.txt');
CMD = sprintf('%s -def %s', CMD, def);

% Run the command and report back if it failed
[status, result] = system(CMD); %#ok<ASGLU> % Just one single result 'outputpoints.txt' is produced

% Check result!
d = dir(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'outputpoints.txt'));
sLobj.data.points = readTransformedPointsFile([fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir), filesep, d.name]);

% Indicate positions outside stack (set to nan)!
for idx = 1:3
    sLobj.data.points.OutputIndexFixed(lt(sLobj.data.points.OutputIndexFixed(:,idx), 1) | gt(sLobj.data.points.OutputIndexFixed(:,idx), stackSize(idx)), idx) = NaN;
end

% Convert back to indices!
IDs = sub2ind(stackSize, ...
    sLobj.data.points.OutputIndexFixed(:,2), ...
    sLobj.data.points.OutputIndexFixed(:,1), ...
    sLobj.data.points.OutputIndexFixed(:,3));

% Add new column to results!
for idx = 1:numel(results)
    IDs_ = IDs(1:voxelN(idx));
    results(idx).VoxelIdxList2 = IDs_;
    IDs = IDs(voxelN(idx)+1:end);
end

warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')

sLobj.statusTextH.String = '';
drawnow


return



