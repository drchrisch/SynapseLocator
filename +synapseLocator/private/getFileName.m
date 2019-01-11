function status = getFileName(sLobj, idx)
%getFileName just gets name of tif file to load

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

idx = num2str(idx);
status = 1;


% Check whether there already was a file opened before!
if isempty(sLobj.dataInputPath)
    pname = '';
else
    pname = sLobj.dataInputPath;
end

[fileName, filePath] = uigetfile(fullfile(pname, '*.tif'), 'Select two channel tif file');

% Check, if a file was selected!
if ~isa(fileName, 'char')
    errordlg('No file selected!','No File Message');
    status = 0;
    sLobj.sLFigH.Pointer = 'arrow';
    return
end

% Test, whether selected file has 'tif' format and an image can be loaded!
[~, ~, ext] = fileparts(fileName);
if ~strcmp(ext,'.tif')
    errordlg('Wrong file format! Please select ''*.tif'' file!','File Selection Error');
    sLobj.sLFigH.Pointer = 'arrow';
    status = [];
    return
end

if ~isempty(fileName)
    sLobj.dataInputPath = filePath;
    sLobj.(['dataFile_', idx]) = fullfile(filePath, fileName);
    if gt(numel(sLobj.(['dataFile_', idx])), 50)
        fileNameDisplay = ['...', sLobj.(['dataFile_', idx])(end-50:end)];
    else
        fileNameDisplay = sLobj.(['dataFile_', idx]);
    end
    % Set file name in GUI
    set(findobj(sLobj.sLFigH, 'Tag', ['dataFile_', idx, '_text']), 'String', fileNameDisplay);
end

end

