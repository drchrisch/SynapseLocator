function [modelName, modelPath, success] = getModelName(sLobj)
%getModelName just gets name of the weka spot model to load

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

success = 0;

[modelName, modelPath] = uigetfile(fullfile(sLobj.synapseLocatorFolder, sLobj.wekaModelsFolder, '*.model'), 'Select weka spot model file');

% Check, if a file was selected!
if ~isa(modelName, 'char')
    modelName = [];
    modelPath = [];
    sLobj.statusTextH.String = 'No model selected!';
    drawnow
    pause(1)
    sLobj.statusTextH.String = '';
    drawnow
    sLobj.sLFigH.Pointer = 'arrow';
    return
end

% Test, whether selected file has 'model' format!
[~, ~, ext] = fileparts(modelName);
if ~strcmp(ext,'.model')
    modelName = [];
    modelPath = [];
    sLobj.statusTextH.String = 'Not a model file!';
    drawnow
    pause(1)
    sLobj.statusTextH.String = '';
    drawnow
    sLobj.sLFigH.Pointer = 'arrow';
    return
end

success = 1;

end

