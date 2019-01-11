function load2ChannelTifFile(sLobj, whichOne)
%load2ChannelTifFile loads two channel image stack from tif file!

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

[~, name_, ~] = fileparts(sLobj.(['dataFile_', whichOne]));

if sLobj.loadTransformed
    copyfile(sLobj.(['dataFile_', whichOne]), fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, [name_, '_prepro.tif']))
end

tifFiles = tmpDirChecker(sLobj);
[~, name_, ~] = fileparts(sLobj.(['dataFile_', whichOne]));


% Load 3D data! Always try to load prepro data (should have undergone complete preprocessing)!
if ischar(tifFiles(str2double(whichOne)).prepro)
    % Load 'prepro' type data!
    filename = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, [name_, '_prepro.tif']);
elseif ischar(tifFiles(str2double(whichOne)).mf)
    % Load 'mf' type data!
    filename = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, [name_, '_mf.tif']);
elseif ischar(tifFiles(str2double(whichOne)).raw)
    % Load raw data!
    filename = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, [name_, '_raw.tif']);
end

% Check for upsampling and apply to all files found in tmpImages
if sLobj.upsampling
    filename_out = regexprep(filename, '.tif$', '_scaled.tif');
    % Call scaleIt macro!
    [imagejSettings, ijRunMode] = sLobj.imageJChecker();
    ijArgs = strjoin({...
        filename, ...
        filename_out, ...
        'upscale', ...
        'double', ...
        ijRunMode},',');
    CMD = sprintf('"%s" %s "%s" "%s"', sLobj.IJ_exe, imagejSettings, fullfile(sLobj.synapseLocatorFolder, sLobj.IJMacrosFolder, sLobj.scaleMacro), ijArgs);
    [status, result] = system(CMD); %#ok<ASGLU>
    
    % Use ScanImageTiffReader! NOTE: ORIENTATION!!!
    tmpData = flipud(rot90(ScanImageTiffReader(filename_out).data, 1));
else
    % Use ScanImageTiffReader! NOTE: ORIENTATION!!!
    tmpData = flipud(rot90(ScanImageTiffReader(filename).data, 1));
end


% Show status in GUI!
sLobj.statusTextH.String = 'Loading Data...';
drawnow

% Store input data in object slot!
if strcmp(whichOne, '1')
    whichOne = '0';
else
    whichOne = '1';
end
sLobj.data.(['G', whichOne]) = double(tmpData(:,:,(1:2:end)));
sLobj.data.(['R', whichOne]) = double(tmpData(:,:,(2:2:end)));
tmpData_ = sLobj.uint16Checker(tmpData(:,:,(1:2:end)));
sLobj.data.(['G', whichOne]) = tmpData_;
tmpData_ = sLobj.uint16Checker(tmpData(:,:,(2:2:end)));
sLobj.data.(['R', whichOne]) = tmpData_;
sLobj.data.(['sizeStack', whichOne]) = uint16(size(tmpData_));

sLobj.statusTextH.String = '';
drawnow

return

