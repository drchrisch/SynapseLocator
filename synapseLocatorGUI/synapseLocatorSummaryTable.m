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

% Last Modified by GUIDE v2.5 10-Jan-2020 13:13:02

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
if isempty(varargin)
    % Organize table user data!
    UserData = struct();
    UserData.sLobj = [];
    UserData.dataShowMode = [];
    UserData.dataProcessType = [];
    UserData.dataSortBy = [];
    UserData.dataPolish = [];
    UserData.excludeSpotsAtEdges = [];
    UserData.dataPolish_G0max_val = [];
    UserData.dataPolish_R0max_val = [];
    UserData.dataPolish_noTwins_val = [];
    UserData.dataFilterBy_dRG0 = [];
    UserData.dataFilterBy_dRG0_val = [];
    UserData.dataFilter_dRGsum = [];
    UserData.dataFilter_dRGsum_val = [];
    UserData.dataFilter_G0G1match = [];
    UserData.dataFilter_G0G1match_val = [];
    UserData.dataFilter_G0R1match = [];
    UserData.dataFilter_G0R1match_val = [];
    UserData.dataFilterBy_dR = [];
    UserData.dataFilterBy_dR_val = [];
    UserData.dataFilterBy_spotMatch = [];
    UserData.dataFilterBy_spotMatch_val = [];
    UserData.allData = [];
    UserData.tmpData = [];
    UserData.spotIntensityHistogramData = struct('processed', [], 'medFiltered', [], 'raw', []);
    UserData.spotIntensityOverviewData = struct('processed', [], 'medFiltered', [], 'raw', []);

    % Position figure!
    arrayfun(@(x) set(x, 'Units', 'normalized'), findobj(handles.figure1, 'Units', 'pixels'), 'Uni', 0)
    arrayfun(@(x) set(x, 'FontUnits', 'normalized'), findobj(handles.figure1, 'FontUnits', 'points'), 'Uni', 0)
%     arrayfun(@(x) set(x, 'Units', 'normalized'), get(handles.figure1, 'Children'), 'uni', 0)
    handles.figure1.Resize = 'on';
%     handles.figure1.Units = 'pixels';
%     screensize = get(groot, 'ScreenSize');
%     handles.figure1.UserData.figure1Position = [1, 1, round(screensize(3) / 2), round(screensize(4) / 1.25)];
    handles.figure1.UserData.figure1Position = [0.6, 0.1, 0.4, 0.8];
    handles.figure1.Position = handles.figure1.UserData.figure1Position;
    movegui(hObject, 'northeast')

%     % Position table!
%     handles.uitable1.Position = [...
%         10,...
%         10,...
%         min([(handles.figure1.Position(3) - 10), round(handles.figure1.Position(3) * 0.98)]),...
%         min([(handles.figure1.Position(4) - 100), round(handles.figure1.Position(4) * 0.9)])];
% 
%     % Position model selection buttongroup!
%     handles.dataShowMode_uibuttongroup.Position = [...
%         10,...
%         (handles.figure1.Position(2) - 50),...
%         handles.dataShowMode_uibuttongroup.Position(3),...
%         handles.dataShowMode_uibuttongroup.Position(4)];


    handles.figure1.UserData = UserData;
else
    % Configure table!
    handles.figure1.UserData.sLobj = varargin{1};

    handles.uitable1.ColumnName = handles.figure1.UserData.sLobj.summaryTableFields;
    handles.uitable1.ColumnWidth = num2cell(repmat(40, 1, numel(handles.uitable1.ColumnName)));

    if handles.figure1.UserData.sLobj.loadRegisteredImages
        handles.dataProcessType_processed_radiobutton.Value = 1;
        handles.dataProcessType_processed_radiobutton.Enable = 'off';
        handles.dataProcessType_medFilt_radiobutton.Enable = 'off';
        handles.dataProcessType_raw_radiobutton.Enable = 'off';
    else
        handles.dataProcessType_processed_radiobutton.Value = 1;
        handles.dataProcessType_processed_radiobutton.Enable = 'on';
        handles.dataProcessType_medFilt_radiobutton.Enable = 'on';
        handles.dataProcessType_raw_radiobutton.Enable = 'on';
    end
    
    handles.figure1.UserData.figure1Position = handles.figure1.Position;

    % Filter and order data for display!
    if ~isempty(handles.figure1.UserData.sLobj.data.G0)
        populateTable(hObject, eventdata, guidata(hObject))
    end
end

% Choose default command line output for synapseLocatorSummaryTable
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = synapseLocatorSummaryTable_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function populateTable(hObject, eventdata, handles)

% Filter data (= filter and re-order data according to 'Mode', 'Data processing', and custom settings)!
labelMode = handles.dataShowMode_uibuttongroup.SelectedObject.String;
processingMode = handles.dataProcessType_uibuttongroup.SelectedObject.String;
sortByMode = handles.dataSortBy_uibuttongroup.SelectedObject.String;

% keyboard
table_ = handles.uitable1;
% ColumnWidth_initial = table_.ColumnWidth;

switch processingMode
    case 'processed'
        tmpData = handles.figure1.UserData.sLobj.synapseLocatorSummary;
    case 'med filtered'
        tmpData = handles.figure1.UserData.sLobj.synapseLocatorSummary_mf;
    case 'raw'
        tmpData = handles.figure1.UserData.sLobj.synapseLocatorSummary_raw;
end

if isempty(tmpData) || eq(numel(tmpData.Spot_ID), 0)
    tmpData = nan(1, numel(table_.ColumnName));
else
    tmpData = struct2table(tmpData);
    tmpData = tmpData(:, ~contains(tmpData.Properties.VariableNames, 'Voxel'));
    
    switch labelMode
        case 'All'
            tmp_idx = true(height(tmpData), 1);
            
            tmpData.outlier = false(height(tmpData), 1);
            
            means_ = mean(tmpData{~tmpData.outlier, {'G0_max', 'R0_max'}});
            channels_text = {'G0_max', 'G1_max'};
            for channels = channels_text
                tmpData.(strrep(channels{:}, '_max', '_norm')) = tmpData.(channels{:}) / means_(1);
            end
            channels_text = {'R0_max', 'R1_max'};
            for channels = channels_text
                tmpData.(strrep(channels{:}, '_max', '_norm')) = tmpData.(channels{:}) / means_(2);
            end
            
            tmpData.r_delta = tmpData.R1_max - tmpData.R0_max;
            tmpData.rDelta_g0 = (tmpData.r_delta / means_(2)) ./ (tmpData.G0_max / means_(1));
            tmpData.rDelta_gSum = (tmpData.r_delta / means_(2)) ./ ((tmpData.G0_max + tmpData.G1_max) / means_(1));
            tmpData.g_ratio = tmpData.G1_max ./ tmpData.G0_max;
            tmpData.r_ratio = tmpData.R1_max ./ tmpData.R0_max;
            tmpData.rg_pre = (tmpData.R0_max / means_(2)) ./ (tmpData.G0_max / means_(1));
            tmpData.rg_post = (tmpData.R1_max / means_(2)) ./ (tmpData.G1_max / means_(1));
            
        case 'default'
            % Remove spots at edges!
            tmpData = tmpData(eq(tmpData.edge, 0),:);

            % Check for outliers!
            Q = quantile(tmpData.R0_max, [0.25, 0.75], 'method', 'exact');
            outThresh = Q(2) + 1.5 * (Q(2) - Q(1));
            tmpData.outlier = gt(tmpData.R0_max, outThresh);
            
            means_ = mean(tmpData{:, {'G0_max', 'R0_max'}});
            channels_text = {'G0_max', 'G1_max'};
            for channels = channels_text
                tmpData.(strrep(channels{:}, '_max', '_norm')) = tmpData.(channels{:}) / means_(1);
            end
            channels_text = {'R0_max', 'R1_max'};
            for channels = channels_text
                tmpData.(strrep(channels{:}, '_max', '_norm')) = tmpData.(channels{:}) / means_(2);
            end

            tmpData.r_delta = tmpData.R1_max - tmpData.R0_max;
            tmpData.rDelta_g0 = (tmpData.r_delta / means_(2)) ./ (tmpData.G0_max / means_(1));
            tmpData.rDelta_gSum = (tmpData.r_delta / means_(2)) ./ ((tmpData.G0_max + tmpData.G1_max) / means_(1));
            tmpData.g_ratio = tmpData.G1_max ./ tmpData.G0_max;
            tmpData.r_ratio = tmpData.R1_max ./ tmpData.R0_max;
            tmpData.rg_pre = (tmpData.R0_max / means_(2)) ./ (tmpData.G0_max / means_(1));
            tmpData.rg_post = (tmpData.R1_max / means_(2)) ./ (tmpData.G1_max / means_(1));
            
            labelMode_idx = ge(tmpData.rDelta_g0, handles.figure1.UserData.sLobj.dRG0Threshold);
            tmp_idx = labelMode_idx;
            
        case 'custom'
            % Check for spots at edges!
            if handles.excludeSpotsAtEdges_radiobutton.Value
                tmpData = tmpData(eq(tmpData.edge, 0),:);
            end

            % Check for twin spots!
            if handles.noTwins_radiobutton.Value
                X = [tmpData.row, tmpData.column, tmpData.section];
                N = size(X, 1);
                XX = sum(X.*X, 2);
                XX1 = repmat(XX,1,N);
                D = XX1 + XX1' - 2*(X*X');
                D(D<0) = 0;
                D = sqrt(D);
                D(D==0) = NaN;
                [dist2Neighbor, ~] = min(D, [], 2, 'omitnan');
                tmpData = tmpData(ge(dist2Neighbor, str2double(handles.dataPolish_noTwins_edit.String)), :);
            end
            
            % Check for outliers!
            if contains(handles.dataPolish_uibuttongroup.SelectedObject.String, 'custom')
                outThreshG0 = str2double(handles.dataPolish_G0max_edit.String);
                outlierG0 = gt(tmpData.G0_max, outThreshG0);

                outThreshR0 = str2double(handles.dataPolish_R0max_edit.String);
                outlierR0 = gt(tmpData.R0_max, outThreshR0);

                tmpData.outlier = false(height(tmpData), 1);
                tmpData.outlier(outlierG0 | outlierR0) = true;
            else
                Q = quantile(tmpData.R0_max, [0.25, 0.75], 'method', 'exact');
                outThresh = Q(2) + 1.5 * (Q(2) - Q(1));
                tmpData.outlier = gt(tmpData.R0_max, outThresh);
            end
            
            means_ = mean(tmpData{:, {'G0_max', 'R0_max'}});
            channels_text = {'G0_max', 'G1_max'};
            for channels = channels_text
                tmpData.(strrep(channels{:}, '_max', '_norm')) = tmpData.(channels{:}) / means_(1);
            end
            channels_text = {'R0_max', 'R1_max'};
            for channels = channels_text
                tmpData.(strrep(channels{:}, '_max', '_norm')) = tmpData.(channels{:}) / means_(2);
            end
            
            tmpData.r_delta = tmpData.R1_max - tmpData.R0_max;
            tmpData.rDelta_g0 = (tmpData.r_delta / means_(2)) ./ (tmpData.G0_max / means_(1));
            tmpData.rDelta_gSum = (tmpData.r_delta / means_(2)) ./ ((tmpData.G0_max + tmpData.G1_max) / means_(1));
            tmpData.g_ratio = tmpData.G1_max ./ tmpData.G0_max;
            tmpData.r_ratio = tmpData.R1_max ./ tmpData.R0_max;
            tmpData.rg_pre = (tmpData.R0_max / means_(2)) ./ (tmpData.G0_max / means_(1));
            tmpData.rg_post = (tmpData.R1_max / means_(2)) ./ (tmpData.G1_max / means_(1));

            % Check filter settings!
            filterBy_idx = true(height(tmpData), 1);

            if handles.dataFilterBy_dRG0_radiobutton.Value
                tmpThresh = str2double(handles.dataFilterBy_dRG0_edit.String);
                filterBy_idx_ = ge(tmpData.rDelta_g0, tmpThresh);
            else
                filterBy_idx_ = filterBy_idx;
            end
            filterBy_idx = filterBy_idx .*filterBy_idx_;
            
            if handles.dataFilterBy_dRGsum_radiobutton.Value
                tmpThresh = str2double(handles.dataFilterBy_dRGsum_edit.String);
                filterBy_idx_ = ge(tmpData.rDelta_gSum, tmpThresh);
            else
                filterBy_idx_ = filterBy_idx;
            end
            filterBy_idx = filterBy_idx .*filterBy_idx_;
            
            if handles.dataFilterBy_dR_radiobutton.Value
                tmpThresh = str2double(handles.dataFilterBy_dR_edit.String);
                filterBy_idx_ = ge(tmpData.r_delta, tmpThresh);
            else
                filterBy_idx_ = filterBy_idx;
            end
            filterBy_idx = filterBy_idx .*filterBy_idx_;

            if handles.dataFilterBy_G0G1match_radiobutton.Value
                tmpThresh = str2double(handles.dataFilterBy_G0G1match_edit.String);
                filterBy_idx_ = ge(tmpData.g0g1_match, tmpThresh);
            else
                filterBy_idx_ = filterBy_idx;
            end
            filterBy_idx = filterBy_idx .*filterBy_idx_;

            if handles.dataFilterBy_G0R1match_radiobutton.Value
                tmpThresh = str2double(handles.dataFilterBy_G0R1match_edit.String);
                filterBy_idx_ = ge(tmpData.g0r1_match, tmpThresh);
            else
                filterBy_idx_ = filterBy_idx;
            end
            filterBy_idx = filterBy_idx .*filterBy_idx_;

            if handles.dataFilterBy_spotMatch_radiobutton.Value
                tmpThresh = str2double(handles.dataFilterBy_spotMatch_edit.String);
                filterBy_idx_ = ge(tmpData.spotMatch_probs, tmpThresh);
            else
                filterBy_idx_ = filterBy_idx;
            end
            filterBy_idx = filterBy_idx .*filterBy_idx_;

            tmp_idx = logical(filterBy_idx);
    end
    
    handles.figure1.UserData.allData = tmpData;
    tmpData = tmpData(~tmpData.outlier & tmp_idx, :);
%     tmpData = tmpData(tmp_idx,:);
    handles.figure1.UserData.tmpData = tmpData;
    
    % Sort!
    switch sortByMode
        case 'dR/G0'
            [~, idx] = sort(tmpData.rDelta_g0, 'descend');
        case 'dR/Gsum'
            [~, idx] = sort(tmpData.rDelta_gSum, 'descend');
        case 'dR'
            [~, idx] = sort(tmpData.r_delta, 'descend');
        case 'G0G1 match'
            [~, idx] = sort(tmpData.g0g1_match, 'descend');
        case 'Spot match'
            [~, idx] = sort(tmpData.spotMatch_probs, 'descend');
    end
    
    tmpData = tmpData(:, handles.figure1.UserData.sLobj.summaryTableFields); % Omit 'VoxelIDs' field!
    tmpData = table2array(tmpData(idx, :));
end

table_.Data = round(tmpData, 2);
% table_.ColumnWidth = ColumnWidth_initial;
someWidth = (handles.figure1.Position .* get(groot, 'ScreenSize')) / numel(handles.uitable1.ColumnName);
handles.uitable1.ColumnWidth = num2cell(repmat(floor(someWidth(3) * 0.95), 1, numel(handles.uitable1.ColumnName)));

if contains(get(findobj(handles.figure1.UserData.sLobj.sLFigH, 'Tag', 'label_uipanel'), 'FontWeight'), 'bold')...
        && get(findobj(handles.figure1.UserData.sLobj.sLFigH, 'Tag', 'label_custom_radiobutton'), 'Value')
    N_ = size(tmpData, 1);
else
    N_ = sum(ge(...
        handles.figure1.UserData.sLobj.synapseLocatorSummary.rDelta_g0(~handles.figure1.UserData.sLobj.synapseLocatorSummary.edge),...
        handles.figure1.UserData.sLobj.dRG0Threshold));
end
set(findobj(handles.figure1.UserData.sLobj.sLFigH, 'Tag', 'labelsN_edit'), 'String', num2str(N_))

funcH = @synapseLocatorGUI;
guiH = guihandles(handles.figure1.UserData.sLobj.sLFigH);
funcH('programmatic_zLevel', guiH)

if handles.livePlot_togglebutton.Value
    plot_pushbutton_Callback(handles.plot_pushbutton, [], handles)
end

return

function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

hObject.ColumnEditable = false;
hObject.RowStriping = 'on';

return

function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Check main GUI status!
if contains(get(findobj(handles.figure1.UserData.sLobj.sLFigH, 'Tag', 'label_uipanel'), 'FontWeight'), 'bold') && get(findobj(handles.figure1.UserData.sLobj.sLFigH, 'Tag', 'label_custom_radiobutton'), 'Value')
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
end

return

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% delete(hObject);

hObject.Visible = 'off';

function dataProcessType_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in dataProcessType_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if contains(handles.dataPolish_uibuttongroup.SelectedObject.String, 'custom') && contains(handles.dataShowMode_uibuttongroup.SelectedObject.String, 'custom')
    intensityPlotter(handles)
end

handles.figure1.UserData.dataProcessType = eventdata.NewValue.String;
populateTable(hObject, eventdata, handles)

return

function dataShowMode_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in dataShowMode_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if contains(eventdata.NewValue.String, 'custom')
    handles.dataPolish_uipanel.Visible = 'on';
    handles.dataFilterBy_uipanel.Visible = 'on';
    if contains(handles.dataPolish_uibuttongroup.SelectedObject.String, 'custom')
    end
else
    handles.dataPolish_uipanel.Visible = 'off';
    handles.dataFilterBy_uipanel.Visible = 'off';
end
intensityPlotter(handles)

handles.figure1.UserData.dataShowMode = eventdata.NewValue.String;
populateTable(hObject, eventdata, handles)

return

function dataSortBy_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in dataSortBy_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.figure1.UserData.dataSortBy = eventdata.NewValue.String;
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_dRG0_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_dRG0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of dataFilterBy_dRG0_edit as text
%        str2double(get(hObject,'String')) returns contents of dataFilterBy_dRG0_edit as a double

handles.figure1.UserData.dataFilter_dRG0_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_dRG0_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_dRG0_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dataFilterBy_dRG0_radiobutton

handles.figure1.UserData.dataFilterBy_dRG0 = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_dRGsum_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_dRGsum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of dataFilterBy_dRGsum_edit as text
%        str2double(get(hObject,'String')) returns contents of dataFilterBy_dRGsum_edit as a double

handles.figure1.UserData.dataFilter_dRGsum_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_dRGsum_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_dRGsum_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of dataFilterBy_dRGsum_radiobutton

handles.figure1.UserData.dataFilterBy_dRGsum = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_dR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_dR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of dataFilterBy_dR_edit as text
%        str2double(get(hObject,'String')) returns contents of dataFilterBy_dR_edit as a double

handles.figure1.UserData.dataFilter_dR_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_dR_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_dR_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of dataFilterBy_dR_radiobutton

handles.figure1.UserData.dataFilterBy_dR = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_G0G1match_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_G0G1match_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of dataFilterBy_G0G1match_edit as text
%        str2double(get(hObject,'String')) returns contents of dataFilterBy_G0G1match_edit as a double

handles.figure1.UserData.dataFilter_G0G1match_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_G0G1match_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_G0G1match_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of dataFilterBy_G0G1match_radiobutton

handles.figure1.UserData.dataFilterBy_G0G1match = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_G0R1match_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_G0R1match_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of dataFilterBy_G0R1match_edit as text
%        str2double(get(hObject,'String')) returns contents of dataFilterBy_G0R1match_edit as a double

handles.figure1.UserData.dataFilter_G0R1match_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_G0R1match_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_G0R1match_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of dataFilterBy_G0R1match_radiobutton

handles.figure1.UserData.dataFilterBy_G0R1match = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_spotMatch_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_spotMatch_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataFilterBy_spotMatch_edit as text
%        str2double(get(hObject,'String')) returns contents of dataFilterBy_spotMatch_edit as a double

handles.figure1.UserData.dataFilter_modelMatch_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataFilterBy_spotMatch_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to dataFilterBy_spotMatch_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of dataFilterBy_spotMatch_radiobutton

handles.figure1.UserData.dataFilterBy_spotMatch = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function dataPolish_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in dataPolish_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if contains(eventdata.NewValue.String, 'custom')
    intensityPlotter(handles)
end

handles.figure1.UserData.dataPolish = eventdata.NewValue.String;
populateTable(hObject, eventdata, handles)

return

function excludeSpotsAtEdges_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to excludeSpotsAtEdges_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of excludeSpotsAtEdges_radiobutton

handles.figure1.UserData.excludeSpotsAtEdges = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function noTwins_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to noTwins_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of noTwins_radiobutton

handles.figure1.UserData.noTwins = get(hObject, 'Value');
populateTable(hObject, eventdata, handles)

return

function intensityPlotter(handles)
% Gather spot intensities and generate histogram, fit, and boxplot!

figHs = findobj('-regexp', 'Name', 'Spot Intensity Histogram');
arrayfun(@(x) set(x, 'Visible', 'off'), figHs)

% Get data!
processingType = handles.dataProcessType_uibuttongroup.SelectedObject.String;
switch processingType
    case 'processed'
        tmpData = handles.figure1.UserData.sLobj.synapseLocatorSummary;
    case 'med filtered'
        tmpData = handles.figure1.UserData.sLobj.synapseLocatorSummary_mf;
        processingType = 'medFiltered';
    case 'raw'
        tmpData = handles.figure1.UserData.sLobj.synapseLocatorSummary_raw;
end

if isempty(tmpData.Spot_ID)
    return
end

figH = handles.figure1.UserData.spotIntensityHistogramData.(processingType);

if isempty(figH)
    figH = figure('Name', 'Spot Intensity Histogram', 'NumberTitle', 'off', 'Position', [1100 600 800 500], 'Units', 'pixels', 'CloseRequestFcn', @intensityPlotterCloseRequestFcn);
    handles.figure1.UserData.spotIntensityHistogramData.(processingType) = figH;
    axH1 = subplot(2, 6, 1:5);
    h1 = histogram((tmpData.G0_max), 'Normalization', 'probability', 'NumBins', 100);
    % Check for license!
    if license('test', 'statistics_toolbox')
        hold on
        pd_kernel = fitdist(tmpData.G0_max, 'Kernel', 'Kernel', 'epanechnikov', 'Width', round(range(tmpData.G0_max)/25));
        %     pd_kernel = fitdist(tmpData.G0_max, 'Kernel', 'Kernel', 'normal');
        %     pd_kernel = fitdist(tmpData.G0_max, 'Lognormal');
        x_values = min(tmpData.G0_max):1:max(tmpData.G0_max);
        y = pdf(pd_kernel, x_values);
        y = (y / max(y)) *  max(h1.Values);
        plot(x_values, y)
        hold off
    end
    axH2 = subplot(2, 6, 6);
    boxplot((tmpData.G0_max));
    
    axH3 = subplot(2, 6, 7:11);
    h3 = histogram((tmpData.R0_max), 'Normalization', 'probability', 'NumBins', 100);
    % Check for license!
    if license('test', 'statistics_toolbox')
        hold on
        pd_kernel = fitdist(tmpData.R0_max, 'Kernel', 'Kernel', 'epanechnikov', 'Width', round(range(tmpData.R0_max)/25));
        %     pd_kernel = fitdist(tmpData.G0_max, 'Kernel', 'Kernel', 'normal');
        %     pd_kernel = fitdist(tmpData.G0_max, 'Lognormal');
        x_values = min(tmpData.R0_max):1:max(tmpData.R0_max);
        y = pdf(pd_kernel, x_values);
        y = (y / max(y)) *  max(h3.Values);
        plot(x_values, y)
        hold off
    end
    axH4 = subplot(2, 6, 12);
    boxplot((tmpData.R0_max));
    
    axH1.YTickLabel = []; axH1.XMinorGrid = 'on';
    axH3.YTickLabel = []; axH3.XMinorGrid = 'on';
    axH2.XTickLabel = []; axH2.YGrid = 'on';
    axH4.XTickLabel = []; axH4.YGrid = 'on';
    annotation(figH, 'textbox', [.05, .8, .5, .2], 'String', ['Spot G0 Intensities (', processingType, ')'], 'LineStyle', 'none', 'FontWeight', 'bold')
    annotation(figH, 'textbox', [.05, .3, .5, .2], 'String', ['Spot R0 Intensities (', processingType, ')'], 'LineStyle', 'none', 'FontWeight', 'bold')
else
    figure(figH)
end

figH.Visible = 'on';

return

function intensityPlotterCloseRequestFcn(src, ~)

src.Visible = 'off';

return

function dataPolish_G0max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataPolish_G0max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of dataPolish_G0max_edit as text
%        str2double(get(hObject,'String')) returns contents of dataPolish_G0max_edit as a double

handles.figure1.UserData.dataPolish_G0max_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataPolish_R0max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataPolish_R0max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of dataPolish_R0max_edit as text
%        str2double(get(hObject,'String')) returns contents of dataPolish_R0max_edit as a double

handles.figure1.UserData.dataPolish_R0max_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return

function dataPolish_noTwins_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dataPolish_noTwins_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataPolish_noTwins_edit as text
%        str2double(get(hObject,'String')) returns contents of dataPolish_noTwins_edit as a double

handles.figure1.UserData.dataPolish_noTwins_val = str2double(get(hObject, 'String'));
populateTable(hObject, eventdata, handles)

return


% --- Executes on button press in livePlot_togglebutton.
function livePlot_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to livePlot_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of livePlot_togglebutton

switch(get(hObject, 'Value'))
    case 0
        handles.plot_pushbutton.Enable = 'on';
    case 1
        handles.plot_pushbutton.Enable = 'off';
end

return

function plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

intensityPlotter(handles)

figHs = findobj('-regexp', 'Name', 'Spot Intensity Overview');
arrayfun(@(x) set(x, 'Visible', 'off'), figHs)

% Get processing mode!
processingType = handles.dataProcessType_uibuttongroup.SelectedObject.String;
switch processingType
    case 'med filtered'
        processingType = 'medFiltered';
end

% Get data!
allData = handles.figure1.UserData.allData;
tmpData = handles.figure1.UserData.tmpData;

if isempty(allData)
    return
end

figH = handles.figure1.UserData.spotIntensityOverviewData.(processingType);

% delete(figHs)
% figH = [];
if isempty(figH)
    figH = figure('Name', 'Spot Intensity Overview', 'NumberTitle', 'off', 'Position', [1100 400 800 666], 'Units', 'pixels', 'CloseRequestFcn', @overviewPlotterCloseRequestFcn);
    handles.figure1.UserData.spotIntensityOverviewData.(processingType) = figH;
    axH1 = subplot(2,2,1);
    scatter(allData.rg_pre(~allData.outlier), allData.rg_post(~allData.outlier), 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5, 'Tag', 'valid')
    hold on
    scatter(allData.rg_pre(allData.outlier), allData.rg_post(allData.outlier), 25, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.05, 'Tag', 'not valid')
    scatter(tmpData.rg_pre(~tmpData.outlier), tmpData.rg_post(~tmpData.outlier), 10, 'o', 'filled', 'MarkerFaceColor', [1.0, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1, 'Tag', 'filtered')
    hold off
%     title('R/G post vs. R/G pre', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
    xlabel('R/G pre', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    ylabel('R/G post', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    set(gca, 'FontSize', 10, 'FontWeight', 'bold')
    grid on; box on
    axH1.Tag = 'pre_post';
    
    axH2 = subplot(2,2,2);
    scatter(allData.G0_norm(~allData.outlier), allData.rDelta_g0(~allData.outlier), 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5, 'Tag', 'valid')
    hold on
    scatter(allData.G0_norm(allData.outlier), allData.rDelta_g0(allData.outlier), 25, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.05, 'Tag', 'not valid')
    scatter(tmpData.G0_norm(~tmpData.outlier), tmpData.rDelta_g0(~tmpData.outlier), 10, 'o', 'filled', 'MarkerFaceColor', [1.0, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1, 'Tag', 'filtered')
    hold off
%     title('dR/G0 vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
    xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    ylabel('dR/G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    set(gca, 'FontSize', 10, 'FontWeight', 'bold')
    grid on; box on
    axH2.Tag = 'rdelta';
    
    axH3 = subplot(2,2,3);
    scatter(allData.g0g1_match(~allData.outlier), allData.g0r1_match(~allData.outlier), 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5, 'Tag', 'valid')
    hold on
    scatter(allData.g0g1_match(allData.outlier), allData.g0r1_match(allData.outlier), 25, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.05, 'Tag', 'not valid')
    scatter(tmpData.g0g1_match(~tmpData.outlier), tmpData.g0r1_match(~tmpData.outlier), 10, 'o', 'filled', 'MarkerFaceColor', [1.0, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1, 'Tag', 'filtered')
    hold off
%     title('g0r1_match vs. g0g1_match', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
    xlabel('g0g1_match', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    ylabel('g0r1_match', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    set(gca, 'FontSize', 10, 'FontWeight', 'bold')
    grid on; box on
    axH3.Tag = 'g0g1r1_corr';

    axH4 = subplot(2,2,4);
    scatter(allData.g0g1_match(~allData.outlier), allData.spotMatch_probs(~allData.outlier), 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5, 'Tag', 'valid')
    hold on
    scatter(allData.g0g1_match(allData.outlier), allData.spotMatch_probs(allData.outlier), 25, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.05, 'Tag', 'not valid')
    scatter(tmpData.g0g1_match(~tmpData.outlier), tmpData.spotMatch_probs(~tmpData.outlier), 10, 'o', 'filled', 'MarkerFaceColor', [1.0, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1, 'tag', 'filtered')
    hold off
%     title('model match vs. g0g1_match', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
    xlabel('g0g1_match', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    ylabel('spotMatch_probs', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
    set(gca, 'FontSize', 10, 'FontWeight', 'bold')
    grid on; box on
    axH4.Tag = 'modelMatch';
    
    annotation(figH, 'textbox', [.02, .8, .5, .2], 'String', ['(', processingType, ' data)'], 'LineStyle', 'none', 'FontWeight', 'bold')
    linkaxes([axH3, axH4], 'x')
else
    axH1 = findobj(figH, 'Tag', 'pre_post');
    axH1_ = findobj(axH1, 'Tag', 'valid');
    axH1_.XData = allData.rg_pre(~allData.outlier);
    axH1_.YData = allData.rg_post(~allData.outlier);
    axH1_ = findobj(axH1, 'Tag', 'not valid');
    axH1_.XData = allData.rg_pre(allData.outlier);
    axH1_.YData = allData.rg_post(allData.outlier);
    axH1_ = findobj(axH1, 'Tag', 'filtered');
    axH1_.XData = tmpData.rg_pre(~tmpData.outlier);
    axH1_.YData = tmpData.rg_post(~tmpData.outlier);  
    axH1.XLimMode = 'auto';
    axH1.YLimMode = 'auto';
    axH2 = findobj(figH, 'Tag', 'rdelta');
    axH2_ = findobj(axH2, 'Tag', 'valid');
    axH2_.XData = allData.G0_max(~allData.outlier);
    axH2_.YData = allData.rDelta_g0(~allData.outlier);
    axH2_ = findobj(axH2, 'Tag', 'not valid');
    axH2_.XData = allData.G0_max(allData.outlier);
    axH2_.YData = allData.rDelta_g0(allData.outlier);
    axH2_ = findobj(axH2, 'Tag', 'filtered');
    axH2_.XData = tmpData.G0_max(~tmpData.outlier);
    axH2_.YData = tmpData.rDelta_g0(~tmpData.outlier);
    axH2.XLimMode = 'auto';
    axH2.YLimMode = 'auto';

    axH3 = findobj(figH, 'Tag', 'g0g1r1_corr');
    axH3_ = findobj(axH3, 'Tag', 'valid');
    axH3_.XData = allData.g0g1_match(~allData.outlier);
    axH3_.YData = allData.g0r1_match(~allData.outlier);
    axH3_ = findobj(axH3, 'Tag', 'not valid');
    axH3_.XData = allData.g0g1_match(allData.outlier);
    axH3_.YData = allData.g0r1_match(allData.outlier);
    axH3_ = findobj(axH3, 'Tag', 'filtered');
    axH3_.XData = tmpData.g0g1_match(~tmpData.outlier);
    axH3_.YData = tmpData.g0r1_match(~tmpData.outlier);
    axH3.XLimMode = 'auto';
    axH3.YLimMode = 'auto';
    axH4 = findobj(figH, 'Tag', 'modelMatch');
    axH4_ = findobj(axH4, 'Tag', 'valid');
    axH4_.XData = allData.g0g1_match(~allData.outlier);
    axH4_.YData = allData.spotMatch_probs(~allData.outlier);
    axH4_ = findobj(axH4, 'Tag', 'not valid');
    axH4_.XData = allData.g0g1_match(allData.outlier);
    axH4_.YData = allData.spotMatch_probs(allData.outlier);
    axH4_ = findobj(axH4, 'Tag', 'filtered');
    axH4_.XData = tmpData.g0g1_match(~tmpData.outlier);
    axH4_.YData = tmpData.spotMatch_probs(~tmpData.outlier);
    axH4.XLimMode = 'auto';
    axH4.YLimMode = 'auto';
    figH.Visible = 'on';
end
figure(figH)

return

function overviewPlotterCloseRequestFcn(src, ~)

src.Visible = 'off';

return

function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get processing type!
processingType = handles.dataProcessType_uibuttongroup.SelectedObject.String;
switch processingType
    case 'med filtered'
        processingType = 'medFiltered';
end

figH = handles.figure1.UserData.spotIntensityHistogramData.(processingType);
if isempty(figH)
    warndlg('No plots available!', 'Warning');
    return
end
filePath = fullfile(handles.figure1.UserData.sLobj.dataOutputPath, ['SpotIntensityHistogramFromTable_', processingType, '.png']);
saveas(figH, filePath);

figH = handles.figure1.UserData.spotIntensityOverviewData.(processingType);
if isempty(figH)
    warndlg('SpotIntensityOverview plot not available!', 'Warning');
else
    filePath = fullfile(handles.figure1.UserData.sLobj.dataOutputPath, ['SpotIntensityOverviewFromTable_', processingType, '.png']);
    saveas(figH, filePath);
end

filePath = fullfile(handles.figure1.UserData.sLobj.dataOutputPath, ['SpotIntensitySummaryFromTable_', processingType, '.csv']);
writetable(handles.figure1.UserData.tmpData(:, ~contains(handles.figure1.UserData.tmpData.Properties.VariableNames, 'generic', 'IgnoreCase', true)),...
    filePath, 'Delimiter', ',', 'QuoteStrings', true)
return





