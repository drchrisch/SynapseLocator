function CMD = registration_prepare(sLobj)
%Make images ready for elastix non-rigid transformation!

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

% Set relevant channels as pre and post ('target' and 'moved')!
target_channel = [sLobj.leadingChannel, '0'];
moved_channel = [sLobj.leadingChannel, '1'];

switch sLobj.leadingChannel
    case 'G'
        second_channel = 'R1';
    case 'R'
        second_channel = 'G1';
end

stackSize_target = size(sLobj.data.(target_channel));
stackSize_moved = size(sLobj.data.(moved_channel));

% Write targetImage to mhd format!
targetFname = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'target');
movedFname = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'moved');

% Check required parameter set!
ok_ = regexp(sLobj.elastixParamsSet, {'default|devel'}, 'start');
ok_ = cat(1, ok_{:});
if isempty(ok_)
    disp('Oooooops!!!!!!!!!!!!!!!!!!!!')
    CMD = [];
    return
else
    % Write targetImage to mhd format!
    mhd_write(sLobj.data.(target_channel), targetFname)
    % Write movingImage to mhd format!
    if sLobj.sum2
        mhd_write(sLobj.data.(moved_channel) + sLobj.data.(second_channel), movedFname)
    else
        mhd_write(sLobj.data.(moved_channel), movedFname)
    end
end

% Check mask setting! Use mask (positive mask, 1 = voxels to keep, 0 = voxels to erode)!
% mask_ = double(gt(sLobj.data.(target_channel), sLobj.data1Threshold));
mask_ = uint8(gt(sLobj.data.(target_channel), int8(sLobj.data1Threshold)));
targetMaskN = sum(mask_(:)); % Count 'active' voxels!
targetMaskFile = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'targetMask');
mhd_write(double(mask_), targetMaskFile);

% mask_ = double(gt(sLobj.data.(moved_channel), sLobj.data2Threshold));
mask_ = uint8(gt(sLobj.data.(moved_channel), int8(sLobj.data2Threshold)));
movedMaskN = sum(mask_(:)); % Count 'active' voxels!
movedMaskFile = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'movedMask');
mhd_write(double(mask_), movedMaskFile);
    
clear mask_

% Set info text!
sLobj.statusTextH.String = 'Image data for elastix are ready ...';
drawnow

% Look for alternative initial rigid transform!
if sLobj.initialTransform
    initialTransformParameterFile = fullfile(sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder, sLobj.initialTransformParametersFile);
    initialTransformParameterFile_tmp = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'initialTransform_parameters.txt');
    if ~copyfile(initialTransformParameterFile, initialTransformParameterFile_tmp, 'f')
        error('Can''t copy file')
    end
    % Modify registration params for choosen run mode!
    initialTransformParams_updateFcn(initialTransformParameterFile_tmp, sLobj.initialTransformParams, size(sLobj.data.G0))
else
    initialTransformParameterFile_tmp = [];
end

% Set elastix parameters list!
elastixParams = dir(fullfile(sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder));
elastixParams = {elastixParams(~[elastixParams.isdir]).name};
elastixParams = elastixParams(contains(elastixParams, sLobj.elastixParamsSet));

translationParameterFile = fullfile(sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder, elastixParams{contains(elastixParams, 'translation')});
translationParameterFile_tmp = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'translation_parameters.txt');
if ~copyfile(translationParameterFile, translationParameterFile_tmp, 'f')
    error('Can''t copy file')
end
rotationParameterFile = fullfile(sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder, elastixParams{contains(elastixParams, 'rotation')});
rotationParameterFile_tmp = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'rotation_parameters.txt');
if ~copyfile(rotationParameterFile, rotationParameterFile_tmp, 'f')
    error('Can''t copy file')
end
affineParameterFile = fullfile(sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder, elastixParams{contains(elastixParams, 'affine')});
affineParameterFile_tmp = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'affine_parameters.txt');
if ~copyfile(affineParameterFile, affineParameterFile_tmp, 'f')
    error('Can''t copy file')
end
elasticParameterFile = fullfile(sLobj.synapseLocatorFolder, sLobj.elastixParamsFolder, elastixParams{contains(elastixParams, 'elastic')});
elasticParameterFile_tmp = fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'elastic_parameters.txt');
if ~copyfile(elasticParameterFile, elasticParameterFile_tmp, 'f')
    error('Can''t copy file')
end


switch sLobj.registrationRunMode
    case 'exhaustive'
        exhaustive_rRM_Fcn({translationParameterFile_tmp, rotationParameterFile_tmp, affineParameterFile_tmp, elasticParameterFile_tmp}, sLobj.FGSIV, sLobj.histogramN, sLobj.resolutionsN, sLobj.apparentSimilarity, sLobj.labelDensity, stackSize_target, stackSize_moved, targetMaskN, movedMaskN, initialTransformParameterFile_tmp)
    case 'default'
        default_rRM_Fcn({translationParameterFile_tmp, rotationParameterFile_tmp, affineParameterFile_tmp, elasticParameterFile_tmp}, sLobj.FGSIV, sLobj.histogramN, sLobj.resolutionsN, sLobj.apparentSimilarity, sLobj.labelDensity, stackSize_target, stackSize_moved, targetMaskN, movedMaskN, initialTransformParameterFile_tmp)
    case 'quick'
        quick_rRM_Fcn({translationParameterFile_tmp, rotationParameterFile_tmp, affineParameterFile_tmp, elasticParameterFile_tmp}, sLobj.FGSIV, sLobj.histogramN, sLobj.resolutionsN, sLobj.apparentSimilarity, sLobj.labelDensity, stackSize_target, stackSize_moved, targetMaskN, movedMaskN, initialTransformParameterFile_tmp)
end

devel_ = regexp(sLobj.elastixParamsSet, {'_devel'}, 'match');
if ~isempty(devel_{:})
    rigidPenaltySetter(elasticParameterFile_tmp, targetMaskName, movedMaskName)
end

% Build the the appropriate command!
elastixCall = sprintf('"%s\\%s\\%s"', sLobj.synapseLocatorFolder, sLobj.elastixFolder, 'elastix');

CMD = sprintf('%s -f "%s.mhd" -m "%s.mhd" -out "%s"',...
            elastixCall,...
            targetFname,...
            movedFname,...
            fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir));

% Check for masks, process and add!
if ~isempty(targetMaskFile)
    CMD = sprintf('%s -fMask "%s.mhd"', CMD, targetMaskFile);
end
if ~isempty(movedMaskFile)
    CMD = sprintf('%s -mMask "%s.mhd"', CMD, movedMaskFile);
end

% Add parameter file names
if sLobj.initialTransform
    CMD = [CMD, sprintf(' -t0 "%s" -p "%s" -p "%s" -p "%s"',...
        initialTransformParameterFile_tmp,...
        rotationParameterFile_tmp,...
        affineParameterFile_tmp,...
        elasticParameterFile_tmp)];
else
    CMD = [CMD, sprintf(' -p "%s" -p "%s" -p "%s" -p "%s"',...
        translationParameterFile_tmp,...
        rotationParameterFile_tmp,...
        affineParameterFile_tmp,...
        elasticParameterFile_tmp)];
end

priority = 'normal'; %'abovenormal'; %'high'; % 'abovenormal' 'normal' 'belownormal'
CMD = sprintf('%s -priority "%s"', CMD, priority);
threads = '4';
CMD = sprintf('%s -threads %s', CMD, threads);

% Store a copy of the command!
cmdFid = fopen(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, 'CMD_R'), 'w');
fprintf(cmdFid, '%s\n', CMD);
fclose(cmdFid);

return

function initialTransformParams_updateFcn(fName, varargin)
% Change registration params!

initialTransformParams = varargin{1};
initialTransformParams([1,2]) = initialTransformParams([2,1]);
initialTransformParams = initialTransformParams .* [-1 1 -1];
imageSize = varargin{2};

fid = fopen(fName);
C = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);
    
C = cat(1, C{:});

C = regexprep(C, '^(TransformParameters.*', ['(TransformParameters ', num2str(initialTransformParams), ')']);
C = regexprep(C, '^(Size.*', ['(Size ', num2str(imageSize), ')']);

fid = fopen(fName, 'w');
fprintf(fid, '%s\n', C{:});
fclose(fid);

return

function exhaustive_rRM_Fcn(fName, varargin)
% Change registration params!

fgsiv_value = varargin{1};
histogramN_value = varargin{2};
numberOfResolutions = varargin{3};
apparentSimilarity = varargin{4};
labelDensity = varargin{5};
stackSize_target = varargin{6};
stackSize_moved = varargin{7};
targetMaskN = varargin{8};
movedMaskN = varargin{9};
initialTransformParameterFile_tmp = varargin{10};

useMask = 1;

for fName_ = fName
    fid = fopen(fName_{:});
    C = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
    fclose(fid);
    
    C = cat(1, C{:});
    
%%%%%%%%%%%%%%%%%%
    C = regexprep(C, '^(FixedInternalImagePixelType.*', '(FixedInternalImagePixelType "short")');
    C = regexprep(C, '^(MovingInternalImagePixelType.*', '(MovingInternalImagePixelType "short")');
    C = regexprep(C, '^(NumberOfResolutions.*', ['(NumberOfResolutions ', num2str(numberOfResolutions), ')']);
%%%%%%%%%%%%%%%%%%

    if isempty(initialTransformParameterFile_tmp)
    else
        newText = sprintf('(%s "%s")\n', 'InitialTransformParametersFileName',  initialTransformParameterFile_tmp);
        if isempty(strfind(fName_{:}, 'translation_par'))
            C = regexprep(C, '^InitialTransformParametersFileName.*', newText);
        end
    end

    if ~isempty(strfind(fName_{:}, 'translation_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        
        C = NiterSetter(C, 'exhaustive', 'translation', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'translation', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'rotation_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'exhaustive', 'rotation', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'rotation', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'affine_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'exhaustive', 'affine', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'affine', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'elastic_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'exhaustive', 'elastic', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'elastic', numberOfResolutions);
        C = regexprep(C, '^(FixedLimitRangeRatio.*', '(FixedLimitRangeRatio 0.0)'); %default 0.01
        C = regexprep(C, '^(MovingLimitRangeRatio.*', '(MovingLimitRangeRatio 0.0)'); %default 0.01        
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^14, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        C = regexprep(C, '^(NumberOfJacobianMeasurements.*', '(NumberOfJacobianMeasurements 100000)');
        schedules = fliplr(2.^(0:(numberOfResolutions - 1)));
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        schedules = repelem(schedules, numberOfResolutions);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FinalGridSpacingInVoxels.*', ['(FinalGridSpacingInVoxels ', num2str(fgsiv_value), ')']);        
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, histogramN_value); % Set histogram
    end
        
    fid = fopen(fName_{:}, 'w');
    fprintf(fid, '%s\n', C{:});
    fclose(fid);
end

return

function default_rRM_Fcn(fName, varargin)
% Change registration params!

fgsiv_value = varargin{1};
histogramN_value = varargin{2};
numberOfResolutions = varargin{3};
apparentSimilarity = varargin{4};
labelDensity = varargin{5};
stackSize_target = varargin{6};
stackSize_moved = varargin{7};
targetMaskN = varargin{8};
movedMaskN = varargin{9};
initialTransformParameterFile_tmp = varargin{10};

useMask = 1;

for fName_ = fName
    fid = fopen(fName_{:});
    C = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
    fclose(fid);
    
    C = cat(1, C{:});
    
%%%%%%%%%%%%%%%%%%
    C = regexprep(C, '^(FixedInternalImagePixelType.*', '(FixedInternalImagePixelType "short")');
    C = regexprep(C, '^(MovingInternalImagePixelType.*', '(MovingInternalImagePixelType "short")');
    C = regexprep(C, '^(NumberOfResolutions.*', ['(NumberOfResolutions ', num2str(numberOfResolutions), ')']);
%%%%%%%%%%%%%%%%%%

    if isempty(initialTransformParameterFile_tmp)
    else
        newText = sprintf('(%s "%s")\n', 'InitialTransformParametersFileName',  initialTransformParameterFile_tmp);
        if isempty(strfind(fName_{:}, 'translation_par'))
            C = regexprep(C, '^InitialTransformParametersFileName.*', newText);
        end
    end
    
    if ~isempty(strfind(fName_{:}, 'translation_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        
        C = NiterSetter(C, 'default', 'translation', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'translation', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'rotation_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'default', 'rotation', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'rotation', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'affine_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'default', 'affine', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'affine', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'elastic_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'default', 'elastic', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'elastic', numberOfResolutions);
        C = regexprep(C, '^(FixedLimitRangeRatio.*', '(FixedLimitRangeRatio 0.0)'); %default 0.01
        C = regexprep(C, '^(MovingLimitRangeRatio.*', '(MovingLimitRangeRatio 0.0)'); %default 0.01        
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^14, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        C = regexprep(C, '^(NumberOfJacobianMeasurements.*', '(NumberOfJacobianMeasurements 100000)');
        schedules = fliplr(2.^(0:(numberOfResolutions - 1)));
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        schedules = repelem(schedules, numberOfResolutions);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FinalGridSpacingInVoxels.*', ['(FinalGridSpacingInVoxels ', num2str(fgsiv_value), ')']);        
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, histogramN_value); % Set histogram
    end
        
    fid = fopen(fName_{:}, 'w');
    fprintf(fid, '%s\n', C{:});
    fclose(fid);
end

return

function quick_rRM_Fcn(fName, varargin)
% Change registration params!

fgsiv_value = varargin{1};
histogramN_value = varargin{2};
numberOfResolutions = varargin{3};
apparentSimilarity = varargin{4};
labelDensity = varargin{5};
stackSize_target = varargin{6};
stackSize_moved = varargin{7};
targetMaskN = varargin{8};
movedMaskN = varargin{9};
initialTransformParameterFile_tmp = varargin{10};

useMask = 1;

for fName_ = fName
    fid = fopen(fName_{:});
    C = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
    fclose(fid);
    
    C = cat(1, C{:});
    
    %%%%%%%%%%%%%%%%%%
    C = regexprep(C, '^(FixedInternalImagePixelType.*', '(FixedInternalImagePixelType "short")');
    C = regexprep(C, '^(MovingInternalImagePixelType.*', '(MovingInternalImagePixelType "short")');
    C = regexprep(C, '^(NumberOfResolutions.*', ['(NumberOfResolutions ', num2str(numberOfResolutions), ')']);
    %%%%%%%%%%%%%%%%%%
    
    if isempty(initialTransformParameterFile_tmp)
    else
        newText = sprintf('(%s "%s")\n', 'InitialTransformParametersFileName',  initialTransformParameterFile_tmp);
        if isempty(strfind(fName_{:}, 'translation_par'))
            C = regexprep(C, '^InitialTransformParametersFileName.*', newText);
        end
    end
    
    if ~isempty(strfind(fName_{:}, 'translation_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        
        C = NiterSetter(C, 'quick', 'translation', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'translation', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'rotation_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'quick', 'rotation', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'rotation', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'affine_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'quick', 'affine', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'affine', numberOfResolutions);
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^13, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        schedules = repelem((fliplr(2.^(0:(numberOfResolutions - 1)))), numberOfResolutions);
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, min([histogramN_value, 32])); % Set histogram
    end
    
    if ~isempty(strfind(fName_{:}, 'elastic_par'))
        C = regexprep(C, '^(MaximumNumberOfSamplingAttempts.*', '(MaximumNumberOfSamplingAttempts 10)');
        C = NiterSetter(C, 'quick', 'elastic', numberOfResolutions);
        C = ratioOfSamplesSetter(C, labelDensity);
        C = stepLengthSetter(C, apparentSimilarity, 'elastic', numberOfResolutions);
        C = regexprep(C, '^(FixedLimitRangeRatio.*', '(FixedLimitRangeRatio 0.0)'); %default 0.01
        C = regexprep(C, '^(MovingLimitRangeRatio.*', '(MovingLimitRangeRatio 0.0)'); %default 0.01
        NOSS = floor(min([prod(stackSize_target)./(linspace(100, 10, numberOfResolutions)); prod(stackSize_moved)./(linspace(100, 10, numberOfResolutions)); repmat(2^14, 1, numberOfResolutions); repmat(targetMaskN, 1, numberOfResolutions); repmat(movedMaskN, 1, numberOfResolutions)]));
        C = regexprep(C, '^(NumberOfSpatialSamples.*', ['(NumberOfSpatialSamples ', num2str(NOSS), ')']);
        C = regexprep(C, '^(NumberOfJacobianMeasurements.*', '(NumberOfJacobianMeasurements 100000)');
        schedules = fliplr(2.^(0:(numberOfResolutions - 1)));
        C = regexprep(C, '^(GridSpacingSchedule.*', ['(GridSpacingSchedule ', num2str(schedules), ')']);
        schedules = repelem(schedules, numberOfResolutions);
        C = regexprep(C, '^(FixedImagePyramidSchedule.*', ['(FixedImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(MovingImagePyramidSchedule.*', ['(MovingImagePyramidSchedule ', num2str(schedules), ')']);
        C = regexprep(C, '^(FinalGridSpacingInVoxels.*', ['(FinalGridSpacingInVoxels ', num2str(fgsiv_value), ')']);        
        C = samplerSetter(C, useMask); % Set image sampler type
        C = bsplineSetter(C, [1,3,3]); % Adjust BSpline order
        C = histogramSetter(C, histogramN_value); % Set histogram
    end    
    
    fid = fopen(fName_{:}, 'w');
    fprintf(fid, '%s\n', C{:});
    fclose(fid);
end

return

function C = bsplineSetter(C, varargin)
orders = varargin{1};
    C = regexprep(C, '^(BSplineInterpolationOrder.*', ['(BSplineInterpolationOrder ', num2str(orders(1)), ')']);
    C = regexprep(C, '^(BSplineTransformSplineOrder.*', ['(BSplineTransformSplineOrder ', num2str(orders(2)), ')']);
    C = regexprep(C, '^(FinalBSplineInterpolationOrder.*', ['(FinalBSplineInterpolationOrder ', num2str(orders(3)), ')']);
return

function C = histogramSetter(C, histBins)
C = regexprep(C, '^(NumberOfHistogramBins.*', ['(NumberOfHistogramBins ', num2str(histBins), ')']);
C = regexprep(C, '^(NumberOfFixedHistogramBins.*', ['(NumberOfFixedHistogramBins ', num2str(histBins), ')']);
C = regexprep(C, '^(NumberOfMovingHistogramBins.*', ['(NumberOfMovingHistogramBins ', num2str(histBins), ')']);
return

function C = samplerSetter(C, varargin)
useMask = varargin{1};
if useMask
    C = regexprep(C, '^(ImageSampler.*', '(ImageSampler "RandomSparseMask")');
else
    C = regexprep(C, '^(ImageSampler.*', '(ImageSampler "Random")');
end
return

function C = stepLengthSetter(C, apparentSimilarity, param, numberOfResolutions)
% Define sets of maximum stepLength and calculate needed values based on
% apparentSimilarity and number of resolutions (define start value successively by 2)! 
        
% Order for each field: translation-rotation-affine-elastic!
maxSL = struct('high', [2, 1, 0.5, 0.25], 'average', [3, 2, 1, 0.5], 'poor', [5, 3, 2, 1]);


switch param
    case 'translation'
        maxSL_ = round(maxSL.(apparentSimilarity)(1) ./ 2.^(0:1:(numberOfResolutions-1)), 3);
    case 'rotation'
        maxSL_ = round(maxSL.(apparentSimilarity)(2) ./ 2.^(0:1:(numberOfResolutions-1)), 3);
    case 'affine'
        maxSL_ = round(maxSL.(apparentSimilarity)(3) ./ 2.^(0:1:(numberOfResolutions-1)), 3);
    case 'elastic'
        maxSL_ = round(maxSL.(apparentSimilarity)(4) ./ 2.^(0:1:(numberOfResolutions-1)), 3);
end
C = regexprep(C, '^(MaximumStepLength.*', ['(MaximumStepLength ', num2str(maxSL_), ')']);
C = regexprep(C, '^(MinimumStepLength.*', ['(MinimumStepLength ', num2str(0), ')']);

return

function C = ratioOfSamplesSetter(C, labelDensity)
% Define sets of RequiredRatioOfValidSamples values based on label sparsity!

rrovs = struct('med', 0.05, 'low', 0.01, 'verylow', 0.001);

C = regexprep(C, '^(RequiredRatioOfValidSamples.*', ['(RequiredRatioOfValidSamples ', num2str(rrovs.(labelDensity)), ')']);

return

function C = NiterSetter(C, runMode, param, numberOfResolutions)
% Define sets of iteration values and calculate needed values based on
% runMode and number of resolutions (define start value successively by 2)! 

% Order for each field: translation-rotation-affine-elastic!
Niter = struct('quick', 500, 'default', 750, 'exhaustive', 1000);
Niter_factor = struct('quick', [1.0, 1.2, 1.2, 1.5], 'default', [1.5, 1.5, 1.5, 1.75], 'exhaustive', [1.5, 1.5, 1.5, 2.0]);

switch param
    case 'translation'
        Niters = round(Niter.(runMode) .* Niter_factor.(runMode)(1).^(0:1:(numberOfResolutions-1)));
    case 'rotation'
        Niters = round(Niter.(runMode) .* Niter_factor.(runMode)(2).^(0:1:(numberOfResolutions-1)));
    case 'affine'
        Niters = round(Niter.(runMode) .* Niter_factor.(runMode)(3).^(0:1:(numberOfResolutions-1)));
    case 'elastic'
        Niters = round(Niter.(runMode) .* Niter_factor.(runMode)(4).^(0:1:(numberOfResolutions-1)));
end
C = regexprep(C, '^(MaximumNumberOfIterations.*', ['(MaximumNumberOfIterations ', num2str(Niters), ')']);

return

function rigidPenaltySetter(fName, targetRigidImageName, movedRigidImageName)

targetRigidImageName = sprintf('"%s.mhd"', targetRigidImageName);
movedRigidImageName = sprintf('"%s.mhd"', movedRigidImageName);

fid = fopen(fName);
C = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);
C = cat(1, C{:});
    
idx = find(cellfun(@(x) ~isempty(regexp(x, '^(FixedRigidityImageName ', 'match')), C));
C{idx} = strrep(C{idx}, C{idx}, ['(FixedRigidityImageName ', targetRigidImageName, ')']);
idx = find(cellfun(@(x) ~isempty(regexp(x, '^(MovingRigidityImageName ', 'match')), C));
C{idx} = strrep(C{idx}, C{idx}, ['(MovingRigidityImageName ', movedRigidImageName, ')']);

fid = fopen(fName, 'w');
fprintf(fid, '%s\n', C{:});
fclose(fid);

return
