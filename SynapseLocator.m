function SynapseLocator()
%SynapseLocator initializes SynapseLocator
%
%
% 
% MATLAB Version: '9.3.0.713579 (R2017b)'
% MATLAB Version: '9.5.0.944444 (R2018b)'
%
% drchrisch@gmail.com
%
% drchrisch10sep2018
% drchrisch30nov2018
% 
%


if isempty(findobj('Name', 'Synapse Locator'))
    % Create waitbar to track process of application!
    wbH = waitbar(0, 'Starting Synapse Locator GUI...', 'Name', 'Synapse Locator Initialization', 'WindowStyle', 'modal', 'Pointer', 'watch');

    % Read parameters from file and set fields in synLoc object!
    mFile = which(mfilename, '-all');    
    [mPath,~,~] = fileparts(mFile{:});    
    paramsFile = dir(fullfile(mPath, 'synapseLocatorParams.csv'));
    paramsFile = fullfile(mPath, paramsFile.name);
    params_ = table2struct(readtable(paramsFile, 'readVariableNames', 0, 'Delimiter', ',', 'CommentStyle', '#'));
    params = struct('SynapseLocatorParameterFile', paramsFile);
    for idx = 1:size(params_, 1)
        params.(params_(idx).Var1) = params_(idx).Var2;
    end
    params.synapseLocatorFolder = mPath;
    
    % Check fiji path and load jars!
    [success, params] = IJ_checker_Fcn(params);
    if ~success
        delete(wbH)
        errordlg('SORRY, NO IMAGEJ INSTALLATION FOUND!', 'ImageJ NOT FOUND')
        return
    end
    
    % Initiate synapseLocator object!
    sLobj = synapseLocator.synLoc();

    % Set parameters!
    paramF = fields(params);
    field_idx = ismember(paramF, fields(sLobj));
    for ps_ = paramF(field_idx)'
        sLobj.(ps_{:}) = params.(ps_{:});
    end
    
    % Convert strings to numbers!
    for sLobjF_ = fields(sLobj)'
        if ischar(sLobj.(sLobjF_{:}))
            if startsWith(sLobj.(sLobjF_{:}), '[') && endsWith(sLobj.(sLobjF_{:}), ']')
                sLobj.(sLobjF_{:}) = strrep(sLobj.(sLobjF_{:}), '[', '');
                sLobj.(sLobjF_{:}) = strrep(sLobj.(sLobjF_{:}), ']', '');
                sLobj.(sLobjF_{:}) = str2double((split(sLobj.(sLobjF_{:}), {' ', ','}))');
            end
            if ~isnan(str2double(sLobj.(sLobjF_{:})))
                sLobj.(sLobjF_{:}) = str2double(sLobj.(sLobjF_{:}));
            end
        end
    end
    
    % Prepare summary tables
    sLobj.summaryFields = strtrim(split(sLobj.summaryFields, ','));
    sLobj.summaryTemplate = struct();
    for tmpField = [sLobj.summaryFields]'
        sLobj.summaryTemplate.(tmpField{:}) = [];
    end
    
    sLobj.summaryTableFields = strtrim(split(sLobj.summaryTableFields, ','));
    sLobj.summaryTableTemplate = struct();
    for tmpField = [sLobj.summaryTableFields]'
        sLobj.summaryTableTemplate.(tmpField{:}) = [];
    end
       
    % Open Synapse Locator GUI!
    synapseLocatorGUI(sLobj)
    
    delete(wbH)
else
    % Bring Synapse Locator GUI to front!
    figure(findobj('Name', 'Synapse Locator'))
end

movegui(findobj('Name', 'Synapse Locator'), 'northwest')

end

function [success, params] = IJ_checker_Fcn(params)
% Look for ImageJ installation!

success = 0;
[filepath_, ~, ~] = fileparts(params.IJ_exe);

if all([exist(filepath_, 'dir'), exist(params.IJ_exe, 'file')])
    % disp('That''s fine!')
    success = 1;
else
    % Try other location!
    dialog_title = 'Select ImageJ Program Folder!';
    IJ_dir = uigetdir(dialog_title);
    if ischar(IJ_dir)
        [filepath_, name_, ext_] = fileparts(params.IJ_exe);
        if all([exist(filepath_, 'dir'), exist(params.IJ_exe, 'file')])
            % Ok, change directory and procede!
            params.IJ_exe = fullfile(filepath_, [name_, ext_]);
            success = 1;
        end
    end    
end

% Load jars!
if success
    % Add jars and plugins!
    ImageJ_loader(params.IJ_exe)
end

end
