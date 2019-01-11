function status = askForNewDir(sLobj)
%Ask for new directory!

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

status = 0;


featureDataDir_old = sLobj.featureDataDir;

% Construct a questdlg with two options
choice = questdlg('Overwrite registration results?', ...
	'Keep directory or create new', ...
    'Yes', 'No', 'Yes');
% Handle response
switch choice
    case 'Yes'
        % That's just fine!
        delete(fullfile(sLobj.dataOutputPath, sLobj.elastixDataDir, '*.*'));
        status = 1;
    case 'No'
        % Create new directory and copy featureData and tmpImages!
        % Ask for output directory!
        tmpImagesDir_old = fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir);
        [status] = setResultPath(sLobj);
        if ~status
            errordlg('Error in making output folder!', 'Data Output Directory Error Message');
            return
        end
        copyfile(tmpImagesDir_old, fullfile(sLobj.dataOutputPath, sLobj.tmpImagesDir));
        status = 1;
    case ''
        errordlg('Error in making output folder!', 'Data Output Directory Error Message');
end

% Check feature data and ask for existing feature folder!
fD = dir(featureDataDir_old);
if ne(sum(ne([fD(:).isdir], 1)), 0) && ~strcmp(featureDataDir_old, sLobj.featureDataDir)
    % Construct a questdlg with two options
    choice = questdlg('Keep feature data?', ...
        'Keep feature data?', ...
        'Yes', 'No', 'Yes');
    % Handle response
    switch choice
        case 'Yes'
            copyfile(featureDataDir_old, sLobj.featureDataDir);
        case {'No', ''}
    end
end

end
