function varargout = synapseLocatorSummaryTable(varargin)
% SYNAPSELOCATORSUMMARYTABLE MATLAB code for synapseLocatorSummaryTable.fig
%      SYNAPSELOCATORSUMMARYTABLE, by itself, creates a new SYNAPSELOCATORSUMMARYTABLE or raises the existing
%      singleton*.
%
%      H = SYNAPSELOCATORSUMMARYTABLE returns the handle to a new SYNAPSELOCATORSUMMARYTABLE or the handle to
%      the existing singleton*.
%
%      SYNAPSELOCATORSUMMARYTABLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYNAPSELOCATORSUMMARYTABLE.M with the given input arguments.
%
%      SYNAPSELOCATORSUMMARYTABLE('Property','Value',...) creates a new SYNAPSELOCATORSUMMARYTABLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before synapseLocatorSummaryTable_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to synapseLocatorSummaryTable_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help synapseLocatorSummaryTable

% Last Modified by GUIDE v2.5 11-Sep-2018 13:34:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @synapseLocatorSummaryTable_OpeningFcn, ...
                   'gui_OutputFcn',  @synapseLocatorSummaryTable_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before synapseLocatorSummaryTable is made visible.
function synapseLocatorSummaryTable_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to synapseLocatorSummaryTable (see VARARGIN)

% 
% drchrisch@gmail.com
%
% cs12dec2018
% 
    
% Run at start!
if isempty(handles.figure1.UserData)
    handles.figure1.UserData.sLobj = varargin{1};

    % Position figure!
    handles.figure1.Units = 'pixels';
    screensize = get(groot, 'ScreenSize');
    handles.figure1.UserData.figure1Position = [1, 1, round(screensize(3) / 2), round(screensize(4) / 2)];
    handles.figure1.Position = handles.figure1.UserData.figure1Position;
    movegui(hObject, 'northeast')

    % Position table!
    handles.uitable1.Position = [10, 10, max([(handles.figure1.Position(3) - 10), round(handles.figure1.Position(3) * 0.98)]), min([(handles.figure1.Position(4) - 60), round(handles.figure1.Position(4) * 0.9)])];

    % Position model selection buttongroup!
    handles.uibuttongroup1.Position = [10, (handles.figure1.Position(2) - 10), round(handles.figure1.Position(3) * 0.5), 30];
    
    % Configure table!
    handles.uitable1.ColumnName = handles.figure1.UserData.sLobj.summaryTableFields;
    handles.uitable1.ColumnWidth = num2cell(repmat(40, 1, numel(handles.uitable1.ColumnName)));    
else
    handles.figure1.UserData.sLobj = varargin{1};
    handles.figure1.UserData.figure1Position = handles.figure1.Position;
end

% Filter and order data for display!
populateTable(hObject, eventdata, guidata(hObject))


% Choose default command line output for synapseLocatorSummaryTable
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = synapseLocatorSummaryTable_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function populateTable(hObject, eventdata, handles, varargin)

% Filter data (= concentrate on signals found by chosen model)!
table_ = handles.uitable1;
tmpData = handles.figure1.UserData.sLobj.synapseLocatorSummary;
ColumnWidth_initial = table_.ColumnWidth;

if ne(size(tmpData, 1), 0)
    tmpData = struct2table(tmpData);
    tmpData = tmpData(:, handles.figure1.UserData.sLobj.summaryTableFields); % Omit 'VoxelIDs' field!
    % Filter!
    if eq(nargin, 4)
        model = varargin{1};
    else
        model = handles.uibuttongroup1.SelectedObject.String;
    end
    model_idx = true(height(tmpData), 1);
    switch model
        case 'All'
            model_idx = true(height(tmpData), 1);
        case 'dR/Gx'
            switch handles.figure1.UserData.sLobj.dRGx
                case 'dR/G0'
                    model_idx = gt(tmpData.rDelta_g0, handles.figure1.UserData.sLobj.dRGxThreshold);
                case 'dR/Gsum'
                    model_idx = gt(tmpData.rDelta_gSum, handles.figure1.UserData.sLobj.dRGxThreshold);
            end
        case 'G0 matched'
            model_idx = tmpData.G0matched == 1;
        case 'Generic matched'
            model_idx = tmpData.Genericmatched == 1;
    end
    tmpData = tmpData(model_idx, :);
    
    % Sort!
    switch handles.figure1.UserData.sLobj.dRGx
        case 'dR/G0'
            [~, idx] = sort(tmpData.rDelta_g0, 'descend');
        case 'dR/Gsum'
            [~, idx] = sort(tmpData.rDelta_gSum, 'descend');
    end
    
    tmpData = table2array(tmpData(idx, :));
else
    tmpData = nan(1, numel(table_.ColumnName));
end
table_.Data = tmpData;
table_.ColumnWidth = ColumnWidth_initial;

return

% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

hObject.ColumnEditable = false;
hObject.RowStriping = 'on';

return

% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Get table index and signal positions!
if ~isempty(eventdata.Indices)
    tableRow = eventdata.Indices(1);
    
    row_ = find(cell2mat(cellfun(@(x) eq(strcmp(x, 'row'), 1), handles.uitable1.ColumnName, 'Uni', 0)));
    column_ = find(cell2mat(cellfun(@(x) eq(strcmp(x, 'column'), 1), handles.uitable1.ColumnName, 'Uni', 0)));
    section_ = find(cell2mat(cellfun(@(x) eq(strcmp(x, 'section'), 1), handles.uitable1.ColumnName, 'Uni', 0)));

    tmpPos = hObject.Data(tableRow, [row_, column_, section_]);
    
    % Check for active zoom and reset!
    % Deactivate zoom button!
    zoom(handles.figure1.UserData.sLobj.imageAxesH, 'off')
    
    % Reset image to full size!
    imSize = size(handles.figure1.UserData.sLobj.data.G0);
    set(handles.figure1.UserData.sLobj.imageAxesH, 'XLim', [1, imSize(2)], 'YLim', [1, imSize(1)])
    
    % Clear zoom range!
    handles.figure1.UserData.sLobj.sLFigH.UserData.zoomXLim = [];
    handles.figure1.UserData.sLobj.sLFigH.UserData.zoomYLim = [];
    
    % Keep image intensity settings!
    
    % Get and set zLevel!
    val = handles.figure1.UserData.sLobj.zRange(2) + 1 - tmpPos(3);
    h = findobj(handles.figure1.UserData.sLobj.sLFigH, 'Tag', 'zLevel_slider');
    h.Value = val;
    hC = get(h,'Callback');
    setappdata(h, 'summaryTable_selection', tmpPos);
    hC(h, [])
end

return


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata, 'All')
    populateTable(hObject, eventdata, handles, eventdata)
else
    populateTable(hObject, eventdata, handles, eventdata.NewValue.String)
end

return


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% delete(hObject);

hObject.Visible = 'off';


% --- Executes on key press with focus on uitable1 and none of its controls.
function uitable1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

keyboard
