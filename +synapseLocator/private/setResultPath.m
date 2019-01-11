function [status] = setResultPath(sLobj)
%setResultPath asks the user to set a path to save all results and important params!

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

status = 1;

% Suggest name and check!
dataOutputPath_ = fullfile(sLobj.dataInputPath, sprintf('SynapseLocator_%s', datestr(now,'yymmdd_HHMMSS')));

prompt={'Synapse Locator Results Dir'};
name = 'Results Dir';
defaultans = {dataOutputPath_};
answer = inputdlg(prompt, name, [1 (length(dataOutputPath_) + 20)], defaultans);
dataOutputPath_ = cat(1, answer{:});
% Check, if a name was given!
if any([isempty(dataOutputPath_), ~isa(dataOutputPath_, 'char')])
    errordlg('No file selected!','No File Message');
    status = 0;
    sLobj.sLFigH.Pointer = 'arrow';
    return
end
if exist(dataOutputPath_, 'dir')
    % Construct a questdlg with two options
    choice = questdlg('Overwrite existing results dir?', 'Overwrite?', 'YES', 'NO', 'NO');
    switch choice
        case 'YES'
            [sts, msg, ~] = rmdir(dataOutputPath_, 's');
            if ~sts
                switch msg
                    case 'Directory already exists.'
                    otherwise
                        status = 0;
                        sLobj.sFH.Pointer = 'arrow';
                        errordlg(msg, 'mkdir error');
                        return
                end
            end
        case 'NO'
            errordlg('Set new output dir name', 'New DirMessage');
            status = 0;
            sLobj.sFH.Pointer = 'arrow';
            return
    end
else
    [sts, msg, ~] = mkdir(dataOutputPath_);
    if ~sts
        
        errordlg(msg, 'mkdir error');
        status = 0;
        sLobj.sFH.Pointer = 'arrow';
        return
    end
end

mkdir(fullfile(dataOutputPath_, sLobj.elastixDataDir));
mkdir(fullfile(dataOutputPath_, sLobj.tmpImagesDir));
mkdir(fullfile(dataOutputPath_, sLobj.featureDataBaseDir));

sLobj.dataOutputPath = dataOutputPath_;
sLobj.featureDataDir = fullfile(dataOutputPath_, sLobj.featureDataBaseDir);

return
