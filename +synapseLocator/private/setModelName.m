function [modelName, modelPath] = setModelName(sLobj)
%setModelName asks the user to set a path to save weka spot model (and weka data!) to file!

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

% Suggest default directory!
pname = fullfile(sLobj.synapseLocatorFolder, sLobj.wekaModelsFolder);

[modelName, modelPath] = uiputfile({'*.model'}, 'Save weka model as', fullfile(pname, 'SLSpotModel'));

% Check, if a file was selected!
if ~isa(modelName, 'char')
    modelName = [];
    sLobj.statusTextH.String = 'No file selected!';
    drawnow
    pause(1)
    sLobj.statusTextH.String = '';
    drawnow
    sLobj.sLFigH.Pointer = 'arrow';
    return
end

% Test, whether selected file has 'model' format and can be loaded!
[~, ~, ext] = fileparts(modelName);
if ~strcmp(ext,'.model')
    modelName = [];
    sLobj.statusTextH.String = 'Wrong file format! Please select ''*.model';
    drawnow
    pause(1)
    sLobj.statusTextH.String = '';
    drawnow
    sLobj.sLFigH.Pointer = 'arrow';
    return
end

end

