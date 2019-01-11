function status = getExistingFeatures(sLobj)
%Load existing feature data

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

status = 0;

% Construct a questdlg with three options
choice = questdlg('Load existing feature set?', ...
	'Load feature set', ...
    'Yes', 'No', 'No');
% Handle response
switch choice
    case 'Yes'
        [defaultPath, ~, ~] = fileparts(sLobj.dataInputPath);
        folder_name = uigetdir(defaultPath, 'Select feature directory');
        if ischar(folder_name)
            if endsWith(folder_name, 'featureData')
                % sLobj.featureDataDir = folder_name;

                copyfile(fullfile(folder_name), fullfile(sLobj.featureDataDir));

                dir_ = dir(fullfile(sLobj.featureDataDir, '*.mat'));
                dir_ = {dir_.name}';
                sLobj.featureNames = strrep(dir_, '.mat', '');
                status = 1;
            end
        else
            return
        end
    case 'No'
end

end