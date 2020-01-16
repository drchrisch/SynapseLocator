function registration_transformation(sLobj)
% Transform (update 'FinalBSplineInterpolationOrder') and save!

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
% cs03dec2019
%


warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')

saveastiff_options.color = false; saveastiff_options.big = false; saveastiff_options.overwrite = true;

if ~isempty(sLobj.transformation_CMD)
    sLobj.statusTextH.String = 'Data are already transformed!';
    drawnow
    pause(3)
    sLobj.statusTextH.String = '';
    drawnow
    return
end

% Get (eventually changed) transform parameters and update 'TransformParameters' file!
FBSIO = sLobj.FBSIO;

% Read translation offset and show in GUI!
if ~sLobj.initialTransform
    d = dir(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'TransformParameters.0.txt'));
    transformParametersFile = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, d(1).name);
    fid = fopen(transformParametersFile);
    C = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
    fclose(fid);
    C = cat(1, C{:});
    offset = str2double(regexp(C{startsWith(C, '(TransformParameters')}, '([-]{0,1}\d+.\d+)', 'match'));
    set(findobj(sLobj.sLFigH, 'Tag', 'initialOffset_edit'), 'String', sprintf('%.1fx%.1fx%.1f', offset([2,1,3])));    
end

% Needed file should be last entry (highest index number)!
d = dir(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'TransformParameters*txt'));
transformParametersFile = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, d(end).name);
transformParametersFile_modified = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'TransformParameters_modified.txt');

fid = fopen(transformParametersFile);
C = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);
C = cat(1, C{:});
    
C = regexprep(C, '^(FinalBSplineInterpolationOrder\s*\w*', ['(FinalBSplineInterpolationOrder ', num2str(FBSIO)]);
C = regexprep(C, '^(ResampleInterpolator.*', '(ResampleInterpolator "FinalBSplineInterpolatorFloat")');
C = regexprep(C, '^(ResultImagePixelType.*', '(ResultImagePixelType "double")');
% C = regexprep(C, '^(ResultImagePixelType.*', '(ResultImagePixelType "short")');

fid = fopen(transformParametersFile_modified, 'w');
fprintf(fid, '%s\n', C{:});
fclose(fid);
clear('C')


% Estimate correlation between image stacks (pre)!
testSize = min([size(sLobj.data.G0); size(sLobj.data.G1)], [], 1);
target_channel = [sLobj.leadingChannel, '0'];
moved_channel = [sLobj.leadingChannel, '1'];
tT = sLobj.data.(target_channel)(1:testSize(1), 1:testSize(2), 1:testSize(3));
tM = sLobj.data.(moved_channel)(1:testSize(1), 1:testSize(2), 1:testSize(3));

tT(lt(tT(:), sLobj.data1OtsuThreshold)) = NaN;
tT(ge(tT(:), sLobj.data1OtsuThreshold)) = 1;
tM(lt(tM(:), sLobj.data2OtsuThreshold)) = NaN;
tM(ge(tM(:), sLobj.data2OtsuThreshold)) = 1;
[sLobj.preTransformationMatch, ~] = corr(single(tT(:)), single(tM(:)), 'Type', 'Pearson', 'Rows', 'complete');

clear tT tM

% Check if actual data 'quality'! Save time point 1 data!
tifFiles = tmpDirChecker(sLobj);
% Load 3D data! Always try to load deconvolved data! (or at least what was named 'deconv' in synLoc 'load2ChannelTif_Fcn' function)!
% Set output name!
if ischar(tifFiles(1).proc)
    saveTiffName_in = tifFiles(1).proc;
    saveTiffName_ext = '_proc.tif';
    transformSuffix = '_proc_transformed.tif';
elseif ischar(tifFiles(1).mf)
    saveTiffName_in = tifFiles(1).mf;
    saveTiffName_ext = '_mf.tif';
    transformSuffix = '_mf_transformed.tif';
else
    saveTiffName_in = tifFiles(1).raw;
    saveTiffName_ext = '_raw.tif';
    transformSuffix = '_raw_transformed.tif';
end

% Save timepoint #0 data, simply copy input! (Note, data used by SynapseLocator might have been changed)!
stack = sLobj.tifLoader(fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, saveTiffName_in));
saveastiff(sLobj.uint16Checker(stack(:,:,1:2:end)), fullfile(sLobj.dataOutputPath, ['G0', saveTiffName_ext]), saveastiff_options);
saveastiff(sLobj.uint16Checker(stack(:,:,2:2:end)), fullfile(sLobj.dataOutputPath, ['R0', saveTiffName_ext]), saveastiff_options);


im2transform = {'G1', 'R1'};
doTransform(sLobj, transformParametersFile_modified, im2transform, transformSuffix)

% Consider 'transformRawData' and save 'raw', 'median filtered' input!
if sLobj.transformRawData && ~sLobj.loadRegisteredImages
    % Reload tifs, save, and transform!
    % Load 3D data at 'raw' and 'mf' quality!
    if ischar(tifFiles(1).mf) && ischar(tifFiles(2).mf)
        % Reload data median filtered #1 and save!
        filename = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, tifFiles(1).mf);
        tmpTiff = sLobj.tifLoader(filename);
        saveastiff(sLobj.uint16Checker(tmpTiff(:,:,(1:2:end))), fullfile(sLobj.dataOutputPath, 'G0_mf.tif'), saveastiff_options);
        saveastiff(sLobj.uint16Checker(tmpTiff(:,:,(2:2:end))), fullfile(sLobj.dataOutputPath, 'R0_mf.tif'), saveastiff_options);
        
        % Reload data #2 transform (do not load into active g1Data/r1Data slot) and save as 'mf_transformed'!
        filename = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, tifFiles(2).mf);
        % Check for upsampling!
        if sLobj.upsampling
            % Call scaleIt macro!
            [imagejSettings, ijRunMode] = sLobj.imageJChecker();
            ijArgs = strjoin({...
                filename, ...
                filename, ...
                'upscale', ...
                'double', ...
                ijRunMode},',');
            CMD = sprintf('"%s" %s "%s" "%s"', sLobj.IJ_exe, imagejSettings, fullfile(sLobj.synapseLocatorFolder, sLobj.IJMacrosFolder, sLobj.scaleMacro), ijArgs);
            [status, result] = system(CMD); %#ok<*ASGLU>
        end

        im2transform = {'G1', 'R1'};
        transformSuffix = '_mf_transformed.tif';
        doTransformReload(sLobj, filename, transformParametersFile_modified, im2transform, transformSuffix)
    end

    if ischar(tifFiles(1).raw) && ischar(tifFiles(2).raw)
        % Reload raw data #1 and save!
        filename = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, tifFiles(1).raw);
        tmpTiff = sLobj.tifLoader(filename);
        saveastiff(sLobj.uint16Checker(tmpTiff(:,:,(1:2:end))), fullfile(sLobj.dataOutputPath, 'G0_raw.tif'), saveastiff_options);
        saveastiff(sLobj.uint16Checker(tmpTiff(:,:,(2:2:end))), fullfile(sLobj.dataOutputPath, 'R0_raw.tif'), saveastiff_options);
        
        % Reload data #2 transform (do not load into active g1Data/r1Data slot) and save as 'mf_transformed'!
        filename = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir, tifFiles(2).raw);
        % Check for upsampling!
        if sLobj.upsampling
            % Call scaleIt macro!
            [imagejSettings, ijRunMode] = sLobj.imageJChecker();
            ijArgs = strjoin({...
                filename, ...
                filename, ...
                'upscale', ...
                'double', ...
                ijRunMode},',');
            CMD = sprintf('"%s" %s "%s" "%s"', sLobj.IJ_exe, imagejSettings, fullfile(sLobj.synapseLocatorFolder, sLobj.IJMacrosFolder, sLobj.scaleMacro), ijArgs);
            [status, result] = system(CMD); 
        end

        im2transform = {'G1', 'R1'};
        transformSuffix = '_raw_transformed.tif';
        doTransformReload(sLobj, filename, transformParametersFile_modified, im2transform, transformSuffix)
    end
end

recycleStatus = recycle;
recycle('off')
delete(transformParametersFile_modified, fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, '*.mhd'), fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, '*.raw'));
recycle(recycleStatus)


% Estimate correlation between image stacks (post)!
target_channel = [sLobj.leadingChannel, '0'];
moved_channel = [sLobj.leadingChannel, '1'];
tT = sLobj.data.(target_channel)(1:testSize(1), 1:testSize(2), 1:testSize(3));
tM = sLobj.data.(moved_channel)(1:testSize(1), 1:testSize(2), 1:testSize(3));
tT(lt(tT(:), sLobj.data1OtsuThreshold)) = NaN;
tT(ge(tT(:), sLobj.data1OtsuThreshold)) = 1;
tM(lt(tM(:), sLobj.data2OtsuThreshold)) = NaN;
tM(ge(tM(:), sLobj.data2OtsuThreshold)) = 1;
[sLobj.postTransformationMatch, ~] = corr(single(tT(:)), single(tM(:)), 'Type', 'Pearson', 'Rows', 'complete');
clear testSize tT tM 

set(sLobj.sLFigH.findobj('Tag', 'preTransformationMatch_edit'), 'String', sprintf('%.1f%%', sLobj.preTransformationMatch * 100))
set(sLobj.sLFigH.findobj('Tag', 'postTransformationMatch_edit'), 'String', sprintf('%.1f%%', sLobj.postTransformationMatch * 100))
fprintf('Correlation pre transformation: %.2f%%\n', sLobj.preTransformationMatch * 100)
fprintf('Correlation post transformation: %.2f%%\n', sLobj.postTransformationMatch * 100)

warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')

return

function CMD = buildCMD(sLobj, movedFname2t, transformParametersFile_modified)

% Build the the appropriate command!
transformixCall = sprintf('"%s\\%s\\%s"', sLobj.synapseLocatorFolder, sLobj.elastixFolder, 'transformix');

targetMask_file = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'targetMask.mhd');
movedMask_file = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'movedMask.mhd');

CMD = sprintf('%s -in "%s.mhd" -out "%s" -fMask "%s" -mMask "%s" -tp "%s"',...
    transformixCall,...
    movedFname2t,...
    fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir),...
    targetMask_file,...
    movedMask_file,...
    transformParametersFile_modified);

priority = 'normal'; %'high'; % 'abovenormal' 'normal' 'belownormal'
CMD = sprintf('%s -priority %s', CMD, priority);

% Store a copy of the command!
sLobj.transformation_CMD = CMD;
cmdFid = fopen(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'CMD_T'), 'w');
fprintf(cmdFid, '%s\n', CMD);
fclose(cmdFid);

return

function doTransform(sLobj, transformParametersFile_modified, im2transform, suffix)

for idx = 1:numel(im2transform)
    movedFname2t = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, ['moved', '2transform']);
    mhd_write(sLobj.data.([im2transform{idx}]), movedFname2t)
    
    % Build the the appropriate command
    CMD = buildCMD(sLobj, movedFname2t, transformParametersFile_modified);
        
    % Run the command and report back if it failed
    [status, result] = system(CMD); % Just one single result 'result.mhd' & 'result.raw' is produced
    
    d = dir(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'result.mhd'));
    % Replace input with transformed input!
    sLobj.data.(im2transform{idx}) = sLobj.uint16Checker(mhd_read([fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir), filesep, d.name]));   
    % Update image max values for display in Spot Finder GUI!
    channelGroup2use = regexp(im2transform{idx}, '^\D{1}', 'match');
    sLobj.sLFigH.UserData.imageMax.(channelGroup2use{:}) = max([sLobj.sLFigH.UserData.imageMax.(channelGroup2use{:}), max(sLobj.data.(im2transform{idx})(:))]);

    saveastiff_options.color = false; saveastiff_options.big = false; saveastiff_options.overwrite = true;
    outputName = fullfile(sLobj.dataOutputPath, [im2transform{idx}, suffix]);
    saveastiff(sLobj.data.(im2transform{idx}), outputName, saveastiff_options);

    % Check for upsampling!
    if sLobj.upsampling
        % Call scaleIt macro!
        [imagejSettings, ijRunMode] = sLobj.imageJChecker();
        ijArgs = strjoin({...
            outputName, ...
            outputName, ...
            'downscale', ...
            'single', ...
            ijRunMode},',');
        CMD = sprintf('"%s" %s "%s" "%s"', sLobj.IJ_exe, imagejSettings, fullfile(sLobj.synapseLocatorFolder, sLobj.IJMacrosFolder, sLobj.scaleMacro), ijArgs);
        [status, result] = system(CMD); 
    end
    
end

return

function doTransformReload(sLobj, file2reload, transformParametersFile_modified, im2transform, suffix)

% Reload data to transform (= dataFile_2)!
tmpTiff = flipud(rot90(ScanImageTiffReader(file2reload).data, 1));


for idx = 1:numel(im2transform)
    movedFname2t = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, ['moved', '2transform']);
    mhd_write((double(tmpTiff(:,:,(idx:2:end)))), movedFname2t)
    
    % Build the the appropriate command
    CMD = buildCMD(sLobj, movedFname2t, transformParametersFile_modified);
        
    % Run the command and report back if it failed
    [~, result] = system(CMD); % Just one single result 'result.mhd' & 'result.raw' is produced
    
    d = dir(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'result.mhd'));
    tmpData = sLobj.uint16Checker(mhd_read([fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir), filesep, d.name]));   
    
    saveastiff_options.color = false; saveastiff_options.big = false; saveastiff_options.overwrite = true;
    outputName = fullfile(sLobj.dataOutputPath, [im2transform{idx}, suffix]);
    saveastiff(tmpData, outputName, saveastiff_options); 
    
    % Check for upsampling!
    if sLobj.upsampling
        % Call scaleIt macro!
        [imagejSettings, ijRunMode] = sLobj.imageJChecker();
        ijArgs = strjoin({...
            outputName, ...
            outputName, ...
            'downscale', ...
            'single', ...
            ijRunMode},',');
        CMD = sprintf('"%s" %s "%s" "%s"', sLobj.IJ_exe, imagejSettings, fullfile(sLobj.synapseLocatorFolder, sLobj.IJMacrosFolder, sLobj.scaleMacro), ijArgs);
        [status, result] = system(CMD);
    end
end

return
