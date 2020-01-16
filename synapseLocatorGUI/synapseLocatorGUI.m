%%
% General stuff
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = synapseLocatorGUI(varargin)
% SYNAPSELOCATORGUI MATLAB code for synapseLocatorGUI.fig
%      SYNAPSELOCATORGUI, by itself, creates a new SYNAPSELOCATORGUI or raises the existing
%      singleton*.
%
%      H = SYNAPSELOCATORGUI returns the handle to a new SYNAPSELOCATORGUI or the handle to
%      the existing singleton*.
%
%      SYNAPSELOCATORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYNAPSELOCATORGUI.M with the given input arguments.
%
%      SYNAPSELOCATORGUI('Property','Value',...) creates a new SYNAPSELOCATORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before synapseLocatorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to synapseLocatorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help synapseLocatorGUI

% Last Modified by GUIDE v2.5 19-Dec-2019 09:59:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @synapseLocatorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @synapseLocatorGUI_OutputFcn, ...
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

function synapseLocatorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to synapseLocatorGUI (see VARARGIN)

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%

% Choose default command line output for synapseLocatorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

handles.statusText_text.String = 'Starting Synapse Locator';

UD = get(handles.synapseLocator_figure, 'UserData');

% Add Synapse Locator object to UserData !
UD.sLobj = varargin{1};
                    
% Add Synapse Locator Figure handles to Synapse Locator object!
UD.sLobj.sLFigH = handles.synapseLocator_figure;
UD.sLobj.imageAxesH = handles.image_axes;
UD.sLobj.sliderLevelH = handles.zLevel_slider;
UD.sLobj.sliderTextH = handles.zLevel_text;
UD.sLobj.statusTextH = handles.statusText_text;
UD.sLobj.modelTextH = handles.model_text;
UD.roi = [];
UD.zoomXLim = [];
UD.zoomYLim = [];
UD.imageIntGMin = 0;
UD.imageIntGMax = 1;
UD.imageIntRMin = 0;
UD.imageIntRMax = 1;
UD.imageMax = struct('G', [], 'R', []);
set(handles.synapseLocator_figure, 'UserData', UD)

% Open summary table and add handle to synapseLocator object!
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH = synapseLocatorSummaryTable();
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.UserData.sLobj = handles.synapseLocator_figure.UserData.sLobj;
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.Visible = 'off';

% Adjust some summary table figure settings
% Set 'Mode'!
set(findobj(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH, 'Tag', 'mode_all_radiobutton'), 'Value', 1)
% Set 'Process'!
set(findobj(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH, 'Tag', 'dataProcessType_processed_radiobutton'), 'Value', 1)
% Set table sort to dR/G0!
set(findobj(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH, 'Tag', 'sortBy_dRG0_radiobutton'), 'Value', 1)

% Set standard operation to single step process control mode!
handles.nStepProcess_pushbutton.String = '2';
handles.runElastix_pushbutton.Visible = 'off';
handles.runElastix_pushbutton.Enable = 'off';
handles.runLocator_pushbutton.Visible = 'off';
handles.runLocator_pushbutton.Enable = 'off';
handles.run_pushbutton.Enable = 'on';
handles.run_pushbutton.Visible = 'on';

% Set leading channel to value defined in Synapse Locator parameter file!
handles.(['leadingChannel_', UD.sLobj.leadingChannel, '_radiobutton']).Value = 1;

% Set spot detection specificity threshold!
handles.spotSpecificity_edit.String = num2str(UD.sLobj.spotSpecificity);

% Set spot detection bwconncompValue!
id_ = strcmp(num2str(UD.sLobj.bwconncompValue), {handles.bwconncompValue_uibuttongroup.Children.String});
handles.bwconncompValue_uibuttongroup.Children(id_).Value = 1;

% Set signal detection specificity threshold!
handles.dRG0Threshold_edit.String = num2str(UD.sLobj.dRG0Threshold);

% Set edge filter (defaults to o)!
handles.excludeSpotsAtEdges_radiobutton.Value = UD.sLobj.excludeSpotsAtEdges;


% Set params for initial image filter!
% % Set median filter/gaussian smoothing!
% id_ = startsWith({handles.smoothing_uibuttongroup.Children.String}, UD.sLobj.smoothing(1:5), 'IgnoreCase', 1);
% handles.smoothing_uibuttongroup.Children(id_).Value = 1;
handles.data1Threshold_edit.String = num2str(UD.sLobj.data1Threshold);
handles.data1Threshold_edit.String = num2str(UD.sLobj.data2Threshold);

% Set threshold for spot finding!
handles.g0_threshold_edit.String = num2str(UD.sLobj.g0_threshold);
handles.g0_threshold_edit.String = num2str(UD.sLobj.g1_threshold);

% handles.voxelSize_edit.String = sprintf('%.2fx%.2fx%.2f', UD.sLobj.vxlSize);
handles.voxelSize_edit.String = [];

% Set params for spot size filter!
handles.spotSizeXmin_edit.String = num2str(UD.sLobj.spotSizeMin(1));
handles.spotSizeYmin_edit.String = num2str(UD.sLobj.spotSizeMin(2));
handles.spotSizeZmin_edit.String = num2str(UD.sLobj.spotSizeMin(3));
handles.spotSizeXmax_edit.String = num2str(UD.sLobj.spotSizeMax(1));
handles.spotSizeYmax_edit.String = num2str(UD.sLobj.spotSizeMax(2));
handles.spotSizeZmax_edit.String = num2str(UD.sLobj.spotSizeMax(3));

% Set elastix parameters list!
elastixParams = dir(fullfile(UD.sLobj.synapseLocatorFolder, UD.sLobj.elastixParamsFolder));
elastixParams = {elastixParams(~[elastixParams.isdir]).name};
hits = cellfun(@(x) regexp(x, '(_parameters_)(\w*)', 'match'), elastixParams, 'Uni', 0);
hits = unique(cat(1,hits{cellfun(@(x) ~isempty(x), hits)}));
[hits, ~] = cellfun(@(x) regexp(x, '(_parameters_)', 'split'), hits, 'Uni', 0);
hitsN = numel(cellfun(@(x) ~isempty(x(1,2)), hits));
hits = arrayfun(@(x) hits{x}(2), 1:hitsN);
value_ = find(contains(hits, UD.sLobj.elastixParamsSet));
handles.elastixParams_listbox.String = hits;
handles.elastixParams_listbox.Value = value_;

% Load default weka model from file!
handles.synapseLocator_figure.Pointer = 'watch';
notify(handles.synapseLocator_figure.UserData.sLobj, 'loadModel', {'default'; UD.sLobj.genericSpotModel})
handles.synapseLocator_figure.Pointer = 'arrow';

% Set raw transformation buton (defaults to off)!
handles.transformRawData_radiobutton.Value = UD.sLobj.transformRawData;

% Set sum G1 and R2 buton (defaults to off)!
handles.sum2_radiobutton.Value = UD.sLobj.sum2;

% Set upsampling button (defaults to off)!
handles.upsampling_radiobutton.Value = UD.sLobj.upsampling;

% Set non-elastix initial transformation status!
handles.initialTransform_radiobutton.Value = UD.sLobj.initialTransform;

% Activate/Deactivate filter (defaults to on)!
handles.filterImages_radiobutton.Value = UD.sLobj.filterImages;

% Set initial offset range!
id_ = strcmp(UD.sLobj.apparentSimilarity, {handles.apparentSimilarity_uibuttongroup.Children.String});
handles.apparentSimilarity_uibuttongroup.Children(id_).Value = 1;

% Set label density!
id_ = strcmp(UD.sLobj.markerDensity, {handles.markerDensity_uibuttongroup.Children.String});
handles.markerDensity_uibuttongroup.Children(id_).Value = 1;

% Set registration run mode!
rmH = findobj('-regexp', 'Tag', 'Registration_radiobutton');
id_ = cell2mat(arrayfun(@(x) ~isempty(regexp(x.Tag, UD.sLobj.registrationRunMode, 'once')), rmH, 'Uni', 0));
rmH(id_).Value = 1;

% Set preprocessing steps!
handles.medianFilter_radiobutton.Value = UD.sLobj.medianFilter;
handles.gaussianSmooth_radiobutton.Value = UD.sLobj.gaussianSmooth;
handles.bandpassFilter_radiobutton.Value = UD.sLobj.bandpassFilter;
handles.subtractBackground_radiobutton.Value = UD.sLobj.subtractBackground;
handles.deconvolve_radiobutton.Value = UD.sLobj.deconvolve;

% Set histogram value!
id_ = strcmp(num2str(UD.sLobj.histogramN), {handles.histogramN_uibuttongroup.Children.String});
handles.histogramN_uibuttongroup.Children(id_).Value = 1;
    
% Set additional elastix params!
handles.FGSIV_edit.String = num2str(UD.sLobj.FGSIV);
handles.FBSIO_edit.String = num2str(UD.sLobj.FBSIO);
handles.resolutionsN_edit.String = num2str(UD.sLobj.resolutionsN);

% Set average spot size!
id_ = contains({handles.avgSpotSize_uibuttongroup.Children.Tag}, UD.sLobj.avgSpotSize);
handles.avgSpotSize_uibuttongroup.Children(id_).Value = 1;

% Set value for making composite tif when saving results!
handles.compositeTif_radiobutton.Value = UD.sLobj.compositeTif;

% Configure image axes!
UD.sLobj.imageAxesH.XTickLabel = [];
UD.sLobj.imageAxesH.YTickLabel = [];
handles.synapseLocator_figure.UserData.zoomH = [];

% Set (dummy) summary table!
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary = handles.synapseLocator_figure.UserData.sLobj.summaryTemplate;
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary_mf = handles.synapseLocator_figure.UserData.sLobj.summaryTemplate;
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary_raw = handles.synapseLocator_figure.UserData.sLobj.summaryTemplate;

% Resize main window!
h = handles.parameter_togglebutton;
set(h, 'Value', 0)
hC = get(h,'Callback');
hC(h, [])

handles.statusText_text.String = '';

return

function varargout = synapseLocatorGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function synapseLocator_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to synapseLocator_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% Close request function to display a question dialog box 
   selection = questdlg('Close This Figure?',...
      'Close Request Function',...
      'Yes','No','No'); 
   switch selection
      case 'Yes'
          clearOnLoad(handles)
          delete(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH);
          delete(hObject);
          delete(findobj('Name', 'Spot Intensity Overview'))
          delete(findobj('Name', 'Spot Intensity Histogram'))
      case 'No'
      return 
   end

delete(hObject)

return

function parameter_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to parameter_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show/hide parameter fields in GUI!
initialPos = handles.synapseLocator_figure.Position;
if get(hObject,'Value')
    handles.synapseLocator_figure.Position = [initialPos(1:2), 1300, 860];
else
    handles.synapseLocator_figure.Position = [initialPos(1:2), 900, 860];
    handles.expertParameters_togglebutton.Value = 0;
end

return

function expertParameters_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to expertParameters_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Show/hide parameter fields in GUI!
initialPos = handles.synapseLocator_figure.Position;
if get(hObject,'Value')
    handles.synapseLocator_figure.Position = [initialPos(1:2), 1700, 860];
else
    handles.synapseLocator_figure.Position = [initialPos(1:2), 1300, 860];
end

return

%%
% Set single/two step processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nStepProcess_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nStepProcess_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nStepProcess_pushbutton
switch hObject.String
    case '2'
        hObject.String = '1';
        handles.run_pushbutton.Visible = 'off';
        handles.run_pushbutton.Enable = 'off';
        handles.runElastix_pushbutton.Enable = 'on';
        handles.runElastix_pushbutton.Visible = 'on';
        handles.runLocator_pushbutton.Enable = 'on';
        handles.runLocator_pushbutton.Visible = 'on';
    case '1'
        hObject.String = '2';
        handles.runElastix_pushbutton.Visible = 'off';
        handles.runElastix_pushbutton.Enable = 'off';
        handles.runLocator_pushbutton.Visible = 'off';
        handles.runLocator_pushbutton.Enable = 'off';
        handles.run_pushbutton.Enable = 'on';
        handles.run_pushbutton.Visible = 'on';
end

return


%%
% Load data, set preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadRegisteredImages_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadRegisteredImages_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load already transformed data! Swith on/off filter options panel!
handles.synapseLocator_figure.UserData.sLobj.loadRegisteredImages = hObject.Value;
if hObject.Value
    handles.imagePreProcessing_uipanel.Visible = 'off';
    handles.registrationParams_uipanel.Visible = 'off';
    handles.filterOptions_uipanel.Visible = 'off';
else
    handles.filterOptions_uipanel.Visible = 'on';
    handles.registrationParams_uipanel.Visible = 'on';
    handles.imagePreProcessing_uipanel.Visible = 'on';
end

preProParamsChanged(handles)

return

function initialTransform_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to initialTransform_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set initial transformation!
handles.synapseLocator_figure.UserData.sLobj.initialTransform = hObject.Value;

preProParamsChanged(handles)

return

function smoothing_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in smoothing_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set channel to use for spot detection!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'medianFilter_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.medianFilter = 1;
        handles.synapseLocator_figure.UserData.sLobj.gaussianSmooth = 0;
    case 'gaussianSmooth_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.medianFilter = 0;
        handles.synapseLocator_figure.UserData.sLobj.gaussianSmooth = 1;
end

preProParamsChanged(handles)

return

function bandpassFilter_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to bandpassFilter_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set bandpass filter step!
handles.synapseLocator_figure.UserData.sLobj.bandpassFilter = hObject.Value;

preProParamsChanged(handles)

return

function subtractBackground_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to subtractBackground_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set background subtration step!
handles.synapseLocator_figure.UserData.sLobj.subtractBackground = hObject.Value;

preProParamsChanged(handles)

return

function deconvolve_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to deconvolve_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set deconvolution step!
handles.synapseLocator_figure.UserData.sLobj.deconvolve = hObject.Value;

preProParamsChanged(handles)

return

function filterImages_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to filterImages_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filterImages_radiobutton
% Activate/Deactivate filter!
handles.synapseLocator_figure.UserData.sLobj.filterImages = hObject.Value;
if hObject.Value
%     handles.filterOptions_uipanel.Visible = 'off';
    handles.medianFilter_radiobutton.Enable = 'on';
    handles.gaussianSmooth_radiobutton.Enable = 'on';
    handles.bandpassFilter_radiobutton.Enable = 'on';
    handles.subtractBackground_radiobutton.Enable = 'on';
    handles.deconvolve_radiobutton.Enable = 'on';
else
%     handles.filterOptions_uipanel.Visible = 'on';
    handles.medianFilter_radiobutton.Enable = 'off';
    handles.gaussianSmooth_radiobutton.Enable = 'off';
    handles.bandpassFilter_radiobutton.Enable = 'off';
    handles.subtractBackground_radiobutton.Enable = 'off';
    handles.deconvolve_radiobutton.Enable = 'off';
end

preProParamsChanged(handles)

return

function imgHistograms_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to imgHistograms_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% delete(findobj('-regexp', 'Name', 'Intensity Histogram'))
delete(findobj('Name', 'Intensity Histogram'))

figure('Name', 'Intensity Histogram', 'NumberTitle', 'off', 'Position', [1200 200 800 500], 'Units', 'pixels')

subplot(1,2,1)
tmpData = handles.synapseLocator_figure.UserData.sLobj.data.G0(:);
tmpData = log10(single(tmpData(gt(tmpData, 0))));
h = histogram(tmpData, 'Normalization', 'probability');
hold on
line([log10(single(handles.synapseLocator_figure.UserData.sLobj.data1Threshold)), log10(single(handles.synapseLocator_figure.UserData.sLobj.data1Threshold))], [min(h.Values), max(h.Values)], 'Color', 'red', 'LineStyle', ':', 'LineWidth', 2)
hold off
title('log10(G0)')

subplot(1,2,2)
tmpData = handles.synapseLocator_figure.UserData.sLobj.data.G1(:);
tmpData = log10(single(tmpData(gt(tmpData, 0))));
h = histogram(tmpData, 'Normalization', 'probability');
hold on
line([log10(single(handles.synapseLocator_figure.UserData.sLobj.data2Threshold)), log10(single(handles.synapseLocator_figure.UserData.sLobj.data2Threshold))], [min(h.Values), max(h.Values)], 'Color', 'red', 'LineStyle', ':', 'LineWidth', 2)
hold off
title('log10(G1)')

return

%%
% Registration params %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function leadingChannelSelect_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in leadingChannelSelect_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set channel to use for spot detection!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'leadingChannel_G_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.leadingChannel = 'G';
    case 'leadingChannel_R_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.leadingChannel = 'R';
end

elastixParamsChanged(handles)

return

function data1Threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to data1Threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data1Threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of data1Threshold_edit as a double

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.data1Threshold = val;

elastixParamsChanged(handles)

return

function data2Threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to data1Threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data1Threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of data1Threshold_edit as a double

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.data2Threshold = val;

elastixParamsChanged(handles)

return

function apparentSimilarity_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in apparentSimilarity_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set step length category!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'apparentSimilarity_good_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.apparentSimilarity = 'good';
    case 'apparentSimilarity_average_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.apparentSimilarity = 'average';
    case 'apparentSimilarity_poor_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.apparentSimilarity = 'poor';
end

elastixParamsChanged(handles)

return

function markerDensity_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in markerDensity_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set step length category!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'markerDensity_high_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.markerDensity = 'high';
    case 'markerDensity_medium_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.markerDensity = 'medium';
    case 'markerDensity_low_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.markerDensity = 'low';
end

elastixParamsChanged(handles)

return

function runMode_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in runMode_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set registration run mode!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'defaultRegistration_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.registrationRunMode = 'default';
    case 'quickRegistration_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.registrationRunMode = 'quick';
    case 'exhaustiveRegistration_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.registrationRunMode = 'exhaustive';
end

elastixParamsChanged(handles)

return

function elastixParams_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to elastixParams_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns elastixParams_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from elastixParams_listbox

contents = cellstr(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.elastixParamsSet = contents{get(hObject,'Value')};

elastixParamsChanged(handles)

return

function histogramN_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in histogramN_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set histogram size for registration!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'histogramN_16_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.histogramN = 16;
    case 'histogramN_24_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.histogramN = 24;
    case 'histogramN_32_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.histogramN = 32;
    case 'histogramN_48_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.histogramN = 48;
    case 'histogramN_64_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.histogramN = 64;
    case 'histogramN_96_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.histogramN = 96;
    case 'histogramN_128_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.histogramN = 128;
end

elastixParamsChanged(handles)

return

function FGSIV_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FGSIV_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FGSIV_edit as text
%        str2double(get(hObject,'String')) returns contents of FGSIV_edit as a double

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.FGSIV = val;

elastixParamsChanged(handles)

return

function FBSIO_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FBSIO_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FBSIO_edit as text
%        str2double(get(hObject,'String')) returns contents of FBSIO_edit as a double

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.FBSIO = val;

elastixParamsChanged(handles)

return

function resolutionsN_edit_Callback(hObject, eventdata, handles)
% hObject    handle to resolutionsN_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.resolutionsN = val;

elastixParamsChanged(handles)

return

%%
% Model generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function class1_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to class1_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns class1_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from class1_listbox

trueVal = handles.synapseLocator_figure.UserData.sLobj.class1_roi{hObject.Value}.pos(3);
val = handles.synapseLocator_figure.UserData.sLobj.zRange(2) + 1 - trueVal;

programmatic_zLevel(handles, val)

return

function class2_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to class2_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns class2_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from class2_listbox

trueVal = handles.synapseLocator_figure.UserData.sLobj.class2_roi{hObject.Value}.pos(3);
val = handles.synapseLocator_figure.UserData.sLobj.zRange(2) + 1 - trueVal;

programmatic_zLevel(handles, val)

return

function class1_listbox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to class1_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Construct a questdlg with three options
choice = questdlg('Delete ROI?', ...
	'Delete ROI Menu', ...
	'DELETE','NO','NO');
% Handle response
switch choice
    case 'DELETE'
        stackPosData = struct('Class', 1, 'ID', hObject.Value);
        notify(handles.synapseLocator_figure.UserData.sLobj, 'deleteROI', stackPosData)
        hObject.String(hObject.Value,:) = [];
        hObject.Value = 1;
        % Simply click zLevel slider!
        programmatic_zLevel(handles)
    case 'NO'
        return
end

return

function class2_listbox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to class2_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Construct a questdlg with three options
choice = questdlg('Delete ROI?', ...
	'Delete ROI Menu', ...
	'DELETE','NO','NO');
% Handle response
switch choice
    case 'DELETE'
        stackPosData = struct('Class', 2, 'ID', hObject.Value);
        notify(handles.synapseLocator_figure.UserData.sLobj, 'deleteROI', stackPosData)
        hObject.String(hObject.Value,:) = [];
        hObject.Value = 1;
        % Simply click zLevel slider!
        programmatic_zLevel(handles)
    case 'NO'
        return
end

return

function class1_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to class1_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get position and pixels!
[roiPos, newString, pixels] = get_ROI_position(handles);

stackPosData = struct('Class', 1, 'ID', [], 'pos', roiPos, 'pixels', pixels, 'features', []);
notify(handles.synapseLocator_figure.UserData.sLobj, 'addROI', stackPosData)

% Add new ROI to list!
handles.class1_listbox.String = [handles.class1_listbox.String; newString];

% Clear roi!
delete(handles.synapseLocator_figure.UserData.roi);
handles.synapseLocator_figure.UserData.roi = [];

% Reset ROI setting buttons!
handles.addROI_pushbutton.ForegroundColor = [0, 0, 0];
handles.addROI_pushbutton.Enable = 'on';
handles.class1_pushbutton.Enable = 'off';
handles.class1_pushbutton.ForegroundColor = [0, 0, 0];
handles.class2_pushbutton.Enable = 'off';
handles.class2_pushbutton.ForegroundColor = [0, 0, 0];

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function class2_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to class2_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get position and pixels!
[roiPos, newString, pixels] = get_ROI_position(handles);

stackPosData = struct('Class', 2, 'ID', [], 'pos', roiPos, 'pixels', pixels, 'features', []);
notify(handles.synapseLocator_figure.UserData.sLobj, 'addROI', stackPosData)

% Add new ROI to list!
handles.class2_listbox.String = [handles.class2_listbox.String; newString];

% Clear roi!
delete(handles.synapseLocator_figure.UserData.roi);
handles.synapseLocator_figure.UserData.roi = [];

% Reset ROI setting buttons!
handles.addROI_pushbutton.ForegroundColor = [0, 0, 0];
handles.addROI_pushbutton.Enable = 'on';
handles.class1_pushbutton.Enable = 'off';
handles.class1_pushbutton.ForegroundColor = [0, 0, 0];
handles.class2_pushbutton.Enable = 'off';
handles.class2_pushbutton.ForegroundColor = [0, 0, 0];

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function addROI_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addROI_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addROI_pushbutton

% Tell user to set ROI and add to class!
handles.addROI_pushbutton.ForegroundColor = [1, 0, 0.1];
hObject.Value = 0;
hObject.Enable = 'inactive';

% Reset toolbar elements!
zoom(handles.image_axes, 'off')
pan(handles.image_axes, 'off')
datacursormode(handles.synapseLocator_figure, 'off')

% Clear old ROI!
delete(handles.synapseLocator_figure.UserData.roi);
handles.synapseLocator_figure.UserData.roi = [];

% Deactivate clicking for existing image!
set(findobj(handles.image_axes, 'Type', 'image'), 'PickableParts', 'none');

% Start ROI drawing!
h = imellipse();
fcn = makeConstrainToRectFcn('imellipse', get(gca, 'XLim'), get(gca, 'YLim'));
% fcn = makeConstrainToRectFcn('impoly', get(gca, 'XLim'), get(gca, 'YLim'));
setPositionConstraintFcn(h, fcn);

% Keep ROI handle!
handles.synapseLocator_figure.UserData.roi = h;

% Activate class buttons!
handles.class1_pushbutton.Enable = 'on';
handles.class1_pushbutton.ForegroundColor = [1, 0, 0.1];
handles.class2_pushbutton.Enable = 'on';
handles.class2_pushbutton.ForegroundColor = [1, 0, 0.1];

return

function clearROIs_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearROIs_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Delete ROIs from synapseLocator!
handles.synapseLocator_figure.Pointer = 'watch';
notify(handles.synapseLocator_figure.UserData.sLobj, 'clearROIs')
handles.synapseLocator_figure.Pointer = 'arrow';

return

function showROI_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to showROI_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of showROI_radiobutton

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

% Simply click zLevel slider!
programmatic_zLevel(handles)

function [stackPos, newString, pixels] = get_ROI_position(handles)    
% Get ROI position and check if pos is just a single pixel and enlarge if so!
% Return corner points!

zLevel = handles.synapseLocator_figure.UserData.sLobj.zLevel;
channel2use = handles.synapseLocator_figure.UserData.sLobj.displayChannel;
stackSize = size(handles.synapseLocator_figure.UserData.sLobj.data.(channel2use));

% pos = getPosition(h) % returns the current position of the rectangle h. The returned position, pos, is a 1-by-4 array [xmin ymin width height].
pos = getPosition(handles.synapseLocator_figure.UserData.roi);
pos(1:2) = pos(1:2) - 0.5;
pos(eq(pos,0)) = 1;
stackPos = [mean([pos(1), pos(1)+pos(3)]), mean([pos(2), pos(2)+pos(4)]), zLevel];

% Make string to add to list!
newString = sprintf('%6.1f %6.1f %3i', stackPos(1), stackPos(2), stackPos(3));

% Get pixels from pos! Calculate voxel ID from pixels!
pixels = find(createMask(handles.synapseLocator_figure.UserData.roi));
if isempty(pixels)
    pixels = uint32(sub2ind(stackSize, stackPos(1), stackPos(2), stackPos(3)));
else
    [x, y] = ind2sub(stackSize(1:2), pixels);
    pixels = sub2ind(stackSize, x, y, repmat(zLevel, numel(x), 1));
end

return

function trainClassifier_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to trainClassifier_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Train classifier!
handles.synapseLocator_figure.Pointer = 'watch';
notify(handles.synapseLocator_figure.UserData.sLobj, 'trainClassifier')
handles.synapseLocator_figure.Pointer = 'arrow';

locatorParamsChanged(handles)

return

function clearModel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearModel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Delete weka model from synapseLocator!
handles.synapseLocator_figure.Pointer = 'watch';
notify(handles.synapseLocator_figure.UserData.sLobj, 'clearModel')
handles.synapseLocator_figure.Pointer = 'arrow';

return

function saveModel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveModel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save weka model to file!
handles.synapseLocator_figure.Pointer = 'watch';
notify(handles.synapseLocator_figure.UserData.sLobj, 'saveModel')
handles.synapseLocator_figure.Pointer = 'arrow';

return

function modelQuality_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to modelQuality_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

notify(handles.synapseLocator_figure.UserData.sLobj, 'modelQuality')

return

function featureStats_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to featureStats_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

notify(handles.synapseLocator_figure.UserData.sLobj, 'featureStats')

return

%%
% Spot detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g0_threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to g0_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.g0_threshold = val;

locatorParamsChanged(handles)

return

function g1_threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to g1_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.g1_threshold = val;

locatorParamsChanged(handles)

return

function bwconncompValue_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bwconncompValue_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set neighborhood value for spot detection!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'bwconncomp_6_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.bwconncompValue = 6;
    case 'bwconncomp_18_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.bwconncompValue = 18;
    case 'bwconncomp_26_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.bwconncompValue = 26;
end

locatorParamsChanged(handles)

return

function spotSizeXmin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spotSizeXmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.spotSizeMin(1) = val;

locatorParamsChanged(handles)

return

function spotSizeXmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spotSizeXmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.spotSizeMax(1) = val;

locatorParamsChanged(handles)

return

function spotSizeYmin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spotSizeYmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.spotSizeMin(2) = val;

locatorParamsChanged(handles)

return

function spotSizeYmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spotSizeYmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.spotSizeMax(2) = val;

locatorParamsChanged(handles)

return

function spotSizeZmin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spotSizeZmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.spotSizeMin(3) = val;

locatorParamsChanged(handles)

return

function spotSizeZmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spotSizeZmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.spotSizeMax(3) = val;

locatorParamsChanged(handles)

return

function spotSpecificity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spotSpecificity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.spotSpecificity = val;

locatorParamsChanged(handles)

return

function genericSpotModel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to genericSpotModel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns genericSpotModel_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from genericSpotModel_listbox

contents = cellstr(get(hObject,'String'));
newEntry = contents{get(hObject,'Value')};

% Load weka model from default directory!
handles.synapseLocator_figure.Pointer = 'watch';
notify(handles.synapseLocator_figure.UserData.sLobj, 'loadModel', {'default'; newEntry})
handles.synapseLocator_figure.Pointer = 'arrow';

locatorParamsChanged(handles)

return

function avgSpotSize_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in avgSpotSize_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set step length category!
inputSelection = get(hObject, 'Tag');

switch inputSelection
    case 'aSS_small_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.avgSpotSize = 'small';
    case 'aSS_medium_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.avgSpotSize = 'medium';
    case 'aSS_large_radiobutton'
        handles.synapseLocator_figure.UserData.sLobj.avgSpotSize = 'large';
end

tmpDir_ = dir(fullfile(handles.synapseLocator_figure.UserData.sLobj.featureDataDir, '*Features'));
if ~isempty(tmpDir_)
    rmdir(fullfile(handles.synapseLocator_figure.UserData.sLobj.featureDataDir, tmpDir_.name), 's')
    delete(fullfile(handles.synapseLocator_figure.UserData.sLobj.featureDataDir, '*.mat'))
    handles.synapseLocator_figure.UserData.sLobj.featureNames = [];
    handles.synapseLocator_figure.UserData.sLobj.featureNames_signalChannel = [];
end

locatorParamsChanged(handles)

return

%%
% Label report %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dRG0Threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dRG0Threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.sLobj.dRG0Threshold = val;

locatorParamsChanged(handles)

return

function excludeSpotsAtEdges_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to excludeSpotsAtEdges_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of excludeSpotsAtEdges_radiobutton

val = get(hObject, 'Value');
handles.synapseLocator_figure.UserData.sLobj.excludeSpotsAtEdges = val;

locatorParamsChanged(handles)

return

%%
% Load data %%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function load2ChannelTif_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load2ChannelTif_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.synapseLocator_figure.Pointer = 'watch';

clearOnLoad(handles)

notify(handles.synapseLocator_figure.UserData.sLobj, 'load2ChannelTif', 'loadData')

handles.synapseLocator_figure.Pointer = 'arrow';

% Check for success!
if all([numel(handles.synapseLocator_figure.UserData.sLobj.data.G0), numel(handles.synapseLocator_figure.UserData.sLobj.data.G1)])
    % Get image max values! Plot!
    handles.synapseLocator_figure.UserData.imageMax.G = ...
        max([max(handles.synapseLocator_figure.UserData.sLobj.data.G0(:)), max(handles.synapseLocator_figure.UserData.sLobj.data.G1(:))]);
    handles.synapseLocator_figure.UserData.imageMax.R = ...
        max([max(handles.synapseLocator_figure.UserData.sLobj.data.R0(:)), max(handles.synapseLocator_figure.UserData.sLobj.data.R1(:))]);
    
    % Simply click zLevel slider!
    programmatic_zLevel(handles)
end

return

function clearOnLoad(handles)

% Check if existing results were saved!
if all([~handles.synapseLocator_figure.UserData.sLobj.resultSaved, ~isempty(handles.synapseLocator_figure.UserData.sLobj.transformation_CMD)])
    selection = questdlg('Save Synapse Locator Results?', 'Save Results', 'Yes', 'No', 'No'); 
    switch selection
        case 'Yes'
            handles.synapseLocator_figure.Pointer = 'watch';
            notify(handles.synapseLocator_figure.UserData.sLobj, 'saveResults')
            handles.synapseLocator_figure.Pointer = 'arrow';
        case 'No'
            recycleStatus = recycle;
            recycle('off')
            [status, message, messageid] = rmdir(handles.synapseLocator_figure.UserData.sLobj.dataOutputPath, 's'); %#ok<ASGLU>
            recycle(recycleStatus)
    end
end

% Reset spot finder summary!
handles.label_default_radiobutton.Value = 1;
% Clear summary figures!
sSLSTH = handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH;
sSLSTH.UserData.allData = [];
sSLSTH.UserData.tmpData = [];
set(findobj(sSLSTH, 'Type', 'uitable'), 'Data', [])
myFields = {'processed', 'medFiltered', 'raw'};
for myField = myFields
    sSLSTH.UserData.spotIntensityHistogramData.(myField{:}) = [];
    sSLSTH.UserData.spotIntensityOverviewData.(myField{:}) = [];
end
delete(findobj('-regexp', 'Name', 'Spot Intensity Histogram'))
delete(findobj('-regexp', 'Name', 'Spot Intensity Overview'))

% Set summary table!
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary = handles.synapseLocator_figure.UserData.sLobj.summaryTemplate;
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary_mf = [];
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary_raw = [];

clearSignalFeatureDataDir(handles)

% Reset data fields in figure and synapseLocator object!
myFields = {'labelsN_edit', 'spotsN_edit', 'initialOffset_edit', 'preTransformationMatch_edit', 'postTransformationMatch_edit'};
for myField = myFields
    handles.(myField{:}).String = {};
end

myFields = {'class1_listbox', 'class2_listbox'};
for myField = myFields
    handles.(myField{:}).String = {};
    handles.(myField{:}).Value = 1;
end

myFields = {'class1_roi', 'class2_roi'};
for myField = myFields
    handles.synapseLocator_figure.UserData.sLobj.(myField{:}) = {};
end

myFields = {...
    'dataOutputPath', ...
    'dataFile_1', 'dataFile_2', ...
    'featureNames', 'featureNames_signalChannel', ...
    'featureDataDir', 'register_CMD', 'transformation_CMD', ...
    'preTransformationMatch', 'postTransformationMatch', ...
    'initialTransformParams'};
for myField = myFields
    handles.synapseLocator_figure.UserData.sLobj.(myField{:}) = [];
end

myFields = {'G0', 'R0', 'G1', 'R1', 'spot_classProbs', 'spot_classProbsStack', 'spot_predicted', 'spot_predictedStack', 'signalModel_G0'};
for myField = myFields
    handles.synapseLocator_figure.UserData.sLobj.data.(myField{:}) = [];
end

myFields = {'preProParamsChanged', 'elastixParamsChanged', 'locatorParamsChanged'};
for myField = myFields
    handles.synapseLocator_figure.UserData.sLobj.internalStuff.(myField{:}) = [];
end

myFields = {...
    'dataFile_1_text', 'dataFile_2_text', ...
    'g0_threshold_edit', 'g0_thresholdSuggestion_edit', 'g1_threshold_edit', 'g1_thresholdSuggestion_edit', ...
    'data1ThresholdSuggestion_edit', 'data2ThresholdSuggestion_edit', ...
    'preTransformationMatch_edit', 'postTransformationMatch_edit'};
for myField = myFields
    handles.(myField{:}).String = '';
end

handles.synapseLocator_figure.UserData.sLobj.resultSaved = 0;

handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH = synapseLocatorSummaryTable(handles.synapseLocator_figure.UserData.sLobj);
handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.Visible = 'off';

handles.spot_uipanel.FontWeight = 'normal';
handles.spot_class_radiobutton.Value = 1;
handles.spot_class_radiobutton.Enable = 'off';
handles.spot_probs_radiobutton.Enable = 'off';
handles.label_uipanel.FontWeight = 'normal';
handles.label_default_radiobutton.Value = 1;
handles.label_default_radiobutton.Enable = 'off';
handles.label_custom_radiobutton.Enable = 'off';

cla(handles.image_axes, 'reset')

return

function clearSignalFeatureDataDir(handles)
% Cleanup of featureData dir!

% Check if featureData dir was created and delete!
if ~isempty(fullfile(handles.synapseLocator_figure.UserData.sLobj.featureDataDir, 'signalFeatures'))
    featureDataDir = fullfile(handles.synapseLocator_figure.UserData.sLobj.featureDataDir, 'signalFeatures');
    [status, message, messageid] = rmdir(featureDataDir, 's'); %#ok<ASGLU>
end

return

%%
% Adjust image axes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayChannel_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in displayChannel_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

handles.synapseLocator_figure.UserData.sLobj.displayChannel = hObject.String;
handles.synapseLocator_figure.UserData.zoomXLim = handles.image_axes.XLim;
handles.synapseLocator_figure.UserData.zoomYLim = handles.image_axes.YLim;

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function minIntensityG_edit_Callback(hObject, eventdata, handles)
% hObject    handle to minIntensityG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minIntensityG_edit as text
%        str2double(get(hObject,'String')) returns contents of minIntensityG_edit as a double

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.imageIntGMin = val;

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function maxIntensityG_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxIntensityG_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIntensityG_edit as text
%        str2double(get(hObject,'String')) returns contents of maxIntensityG_edit as a double

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.imageIntGMax = val;

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function minIntensityR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to minIntensityR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minIntensityR_edit as text
%        str2double(get(hObject,'String')) returns contents of minIntensityR_edit as a double

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.imageIntRMin = val;

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function maxIntensityR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxIntensityR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIntensityR_edit as text
%        str2double(get(hObject,'String')) returns contents of maxIntensityR_edit as a double

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

val = str2double(get(hObject,'String'));
handles.synapseLocator_figure.UserData.imageIntRMax = val;

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function image_input_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to image_input_1_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of image_input_1_radiobutton

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function spot_results_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in spot_results_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function spot_uipanel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to spot_uipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

switch hObject.FontWeight
    case 'normal'
        hObject.FontWeight = 'bold';
        handles.spot_class_radiobutton.Enable = 'on';
        handles.spot_probs_radiobutton.Enable = 'on';
    case 'bold'
        hObject.FontWeight = 'normal';
        handles.spot_class_radiobutton.Enable = 'off';
        handles.spot_probs_radiobutton.Enable = 'off';
end

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function label_results_uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in label_results_uibuttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

switch hObject.String
    case 'custom threshold'
        % Allow user to pick individual label entry from table and indicate position!
        % Make summary table visible!
        summary = handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.UserData.tmpData;
        if isempty(summary)
            handles.labelsN_edit.String = '';
        else
            handles.labelsN_edit.String = num2str(height(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.UserData.tmpData));
        end
        handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.Visible = 'on';
        figure(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH);
    otherwise
        % Show all labels based on 'Label Report Expert' criteria!
        N_ = sum(ge(...
            handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary.rDelta_g0(~handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary.edge),...
            handles.synapseLocator_figure.UserData.sLobj.dRG0Threshold));
        handles.labelsN_edit.String = num2str(N_);
end
% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function label_uipanel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to label_uipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    return
end

switch hObject.FontWeight
    case 'normal'
        hObject.FontWeight = 'bold';
        handles.label_default_radiobutton.Enable = 'on';
        handles.label_custom_radiobutton.Enable = 'on';
        if handles.label_custom_radiobutton.Value
            summary = handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.UserData.tmpData;
            if isempty(summary)
                handles.labelsN_edit.String = '';
            else
                handles.labelsN_edit.String = num2str(height(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.UserData.tmpData));
            end
            handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.Visible = 'on';
            figure(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH);            
        else
            N_ = sum(ge(...
                handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary.rDelta_g0(~handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary.edge),...
                handles.synapseLocator_figure.UserData.sLobj.dRG0Threshold));
            handles.labelsN_edit.String = num2str(N_);
        end
    case 'bold'
        hObject.FontWeight = 'normal';
        handles.label_default_radiobutton.Enable = 'off';
        handles.label_custom_radiobutton.Enable = 'off';
        N_ = sum(ge(...
            handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary.rDelta_g0(~handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary.edge),...
            handles.synapseLocator_figure.UserData.sLobj.dRG0Threshold));
        handles.labelsN_edit.String = num2str(N_);
end

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

function zLevel_slider_Callback(hObject, eventdata, handles)
% hObject    handle to zLevel_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = round(get(hObject,'Value'));
trueVal = val;
trueVal = handles.synapseLocator_figure.UserData.sLobj.zRange(2) + 1 - trueVal;

% Update zLevel field in GUI and synapseLocator obj!
handles.zLevel_text.String = num2str(trueVal);
handles.synapseLocator_figure.UserData.sLobj.zLevel = trueVal;

% delete(findobj(handles.image_axes, 'Type', 'hggroup'))
delete(handles.image_axes.Children(:))

% Update plot!
channel2use = handles.synapseLocator_figure.UserData.sLobj.displayChannel;
channelGroup2use = regexp(handles.synapseLocator_figure.UserData.sLobj.displayChannel, '^\D{1}', 'match');

imgSize = size(handles.synapseLocator_figure.UserData.sLobj.data.(channel2use));
imageMax = handles.synapseLocator_figure.UserData.imageMax.(channelGroup2use{:});
imageIntMin = handles.synapseLocator_figure.UserData.(['imageInt', channelGroup2use{:}, 'Min']) * imageMax;
imageIntMax = handles.synapseLocator_figure.UserData.(['imageInt', channelGroup2use{:}, 'Max']) * imageMax;

if isempty(imageMax)
    return
end

axes(handles.image_axes);
xlim_ = [ceil(handles.image_axes.XLim(1)), floor(handles.image_axes.XLim(2))];
% ylim_ = [ceil(handles.image_axes.YLim(1)), floor(handles.image_axes.YLim(2))];
zFactor = imgSize(1) / diff(xlim_);
if handles.image_input_radiobutton.Value
    imagesc(handles.synapseLocator_figure.UserData.sLobj.data.(channel2use)(:,:,trueVal), [imageIntMin, imageIntMax])
else
    imagesc(ones(imgSize(1), imgSize(2)));
end

% Prepare to plot spots!
if strcmp(handles.spot_uipanel.FontWeight, 'bold') || strcmp(handles.label_uipanel.FontWeight, 'bold')
    summary = handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary;
end

% Plot spots!
if strcmp(handles.spot_uipanel.FontWeight, 'bold') && ~isempty(handles.synapseLocator_figure.UserData.sLobj.data.spot_predictedStack)
    if strcmp(handles.spot_results_uibuttongroup.SelectedObject.String, 'Spot Voxels')
        tmpSpots = handles.synapseLocator_figure.UserData.sLobj.data.spot_classProbsStack(:,:,trueVal);
        spotPlotMarker = 'x';
        spotPlotColor = [0.1,0.1,0.1];
        spotPlotMarkerFaceColor = [0.7,1,0.7];
        spotPlotLineWidth = 2;
        spotPlotSize = 1 * zFactor;

        hold on
        spy(tmpSpots)
        hold off
        
        sH = findobj(handles.image_axes, 'Type', 'Line', '-and', 'Tag', '');
        sH.Marker = spotPlotMarker;
        sH.Color = spotPlotColor;
        sH.MarkerFaceColor = spotPlotMarkerFaceColor;
        sH.MarkerSize = spotPlotSize;
        sH.LineWidth = spotPlotLineWidth;
        sH.Tag = 'done';
    else
        level = -2:1:2;
        spotPlotMarker = 'o';
        spotPlotColor = [0.1,0.1,0.1];
        spotPlotLineWidth = [0.2, 0.5, 1, 0.5, 0.2];
        spotPlotMarkerFaceColor = [repmat(0.1, 5, 1), [0.2; 0.35; 1; 0.35; 0.2], repmat(0.1, 5, 1)];
        spotPlotSize = [1, 3, 5, 3, 1];
        spotPlotSize = spotPlotSize * sqrt(zFactor);

        for idx = 1:numel(level)
            tmpSpots = zeros(imgSize(1), imgSize(2));
            tmpX = summary.row(eq(summary.section, trueVal + level(idx)));
            tmpY = summary.column(eq(summary.section, trueVal + level(idx)));
            tmpSpots(sub2ind(imgSize(1:2), tmpX, tmpY)) = 1;
            
            hold on
            spy(tmpSpots)
            hold off
            
            sH = findobj(handles.image_axes, 'Type', 'Line', '-and', 'Tag', '');
            sH.Color = spotPlotColor;
            sH.Marker = spotPlotMarker;
            sH.MarkerFaceColor = spotPlotMarkerFaceColor(idx,:);
            sH.MarkerSize = spotPlotSize(idx);
            sH.LineWidth = spotPlotLineWidth(idx);
            sH.Tag = 'done';
        end
    end    
end

% Plot labels!
if strcmp(handles.label_uipanel.FontWeight, 'bold')
    % Prepare to plot labels!
    switch handles.label_results_uibuttongroup.SelectedObject.String
        case 'default threshold'
            summary = handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary;
            tmpIdx = ge(summary.rDelta_g0, handles.synapseLocator_figure.UserData.sLobj.dRG0Threshold);
        case 'custom threshold'
            summary = handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummaryTableH.UserData.tmpData;
            if ~isempty(summary)
                summary = table2dataset(summary);
            else
                summary = [];
            end
            tmpIdx = true(size(summary, 1), 1);
    end
    if gt(numel(handles.synapseLocator_figure.UserData.sLobj.synapseLocatorSummary.Spot_ID), 0)
        if ~isempty(summary)
            level = -2:1:2;
            spotPlotSize = [1, 3, 5, 3, 1];
            spotPlotSize = spotPlotSize * 0.9 * sqrt(zFactor);
            spotPlotMarker = 'o';
            spotPlotColor = [0.1,0.1,0.1];
            spotPlotLineWidth = [0.2, 0.5, 1, 0.5, 0.2];
            spotPlotMarkerFaceColor = [repmat(0.9, 5, 1), repmat(0.1, 5, 1), repmat(0.1, 5, 1)];
            
            for idx = 1:numel(level)
                tmpSpots = zeros(imgSize(1), imgSize(2));
                tmpX = summary.row(eq(summary.section, trueVal + level(idx)) & tmpIdx);
                tmpY = summary.column(eq(summary.section, trueVal + level(idx)) & tmpIdx);
                tmpSpots(sub2ind(imgSize(1:2), tmpX, tmpY)) = 1;
                
                hold on
                spy(tmpSpots)
                hold off
                
                sH = findobj(handles.image_axes, 'Type', 'Line', '-and', 'Tag', '');
                sH.Color = spotPlotColor;
                sH.Marker = spotPlotMarker;
                sH.MarkerFaceColor = spotPlotMarkerFaceColor(idx,:);
                sH.MarkerSize = spotPlotSize(idx);
                sH.LineWidth = spotPlotLineWidth(idx);
                sH.Tag = 'done';
            end
        end
    end
end

if ~isempty(handles.synapseLocator_figure.UserData.zoomXLim)
    set(handles.image_axes, 'XLim', handles.synapseLocator_figure.UserData.zoomXLim, 'YLim', handles.synapseLocator_figure.UserData.zoomYLim)
end

if handles.showROI_radiobutton.Value
    for class_roi = {'class1_roi', 'class2_roi'}
        if ~isempty(class_roi)
            class_roi_data = handles.synapseLocator_figure.UserData.sLobj.(class_roi{:});
            if ~isempty(class_roi_data)
                for idx = 1:numel(class_roi_data)
                    if eq(class_roi_data{idx}.pos(3), trueVal)
                        switch class_roi{1}
                            case 'class1_roi'
                                hold on
                                scatter(class_roi_data{idx}.pos(1), class_roi_data{idx}.pos(2), 'k', 'LineWidth', 2, 'SizeData', 500,...
                                    'Marker', 'p', 'MarkerEdgeColor', [0.05, 0.05, 0.05], 'MarkerFaceColor', [1,0,0], 'Tag', 'roi')
                                hold off
                            case 'class2_roi'
                                hold on
                                scatter(class_roi_data{idx}.pos(1), class_roi_data{idx}.pos(2), 'k', 'LineWidth', 2, 'SizeData', 500,...
                                    'Marker', 'p', 'MarkerEdgeColor', [0.05, 0.05, 0.05], 'MarkerFaceColor', [0,1,0], 'Tag', 'roi')
                                hold off
                        end
                    end
                end
            end
        end
    end
end

% Respond to entry selected in synapse locator summary table!
appData = getappdata(hObject);
if strcmp(handles.label_uipanel.FontWeight, 'bold')
    if strcmp(handles.label_results_uibuttongroup.SelectedObject.String, 'custom threshold')
        if isfield(appData, 'summaryTable_selection')
            if eq(appData.summaryTable_selection(3), trueVal)
                hold on
                plot(handles.image_axes, appData.summaryTable_selection(2), appData.summaryTable_selection(1), 'Marker', 'o', 'MarkerSize', 45, 'LineWidth', 3, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'LineStyle', 'none')
                hold off
            end
            rmappdata(hObject, 'summaryTable_selection')
        end
    end
end

return

function programmatic_zLevel(handles, varargin)
% Prepare to call zLevel slider!
if isempty(varargin)
    val = handles.zLevel_slider.Value;
else
    val = varargin{1};
end
h = handles.zLevel_slider;
set(h, 'Value', val)
hC = get(h,'Callback');
hC(h, [])

return

function zoomIn_uitoggletool_OnCallback(hObject, eventdata, handles)
% hObject    handle to zoomIn_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.zoomH)
    handles.synapseLocator_figure.UserData.zoomH = zoom;
else
    zoom(handles.image_axes, 'off')
    handles.synapseLocator_figure.UserData.zoomH = zoom;
end
handles.synapseLocator_figure.UserData.zoomH.ActionPostCallback = @(hObject, eventdata)zoom_postcallback(hObject, eventdata, handles);
handles.synapseLocator_figure.UserData.zoomH.Direction = 'in';
zoom(handles.image_axes, 'on')

return

function zoomIn_uitoggletool_OffCallback(hObject, eventdata, handles)
% hObject    handle to zoomIn_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom off
handles.synapseLocator_figure.UserData.zoomH = [];

return

function zoomIn_uitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to zoomIn_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return

% --------------------------------------------------------------------
function zoomOut_uitoggletool_OnCallback(hObject, eventdata, handles)
% hObject    handle to zoomOut_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.zoomH)
    handles.synapseLocator_figure.UserData.zoomH = zoom;
else
    zoom(handles.image_axes, 'off')
    handles.synapseLocator_figure.UserData.zoomH = zoom;
end
handles.synapseLocator_figure.UserData.zoomH.ActionPostCallback = @(hObject, eventdata)zoom_postcallback(hObject, eventdata, handles);
handles.synapseLocator_figure.UserData.zoomH.Direction = 'out';
zoom(handles.image_axes, 'on')

return

function zoomOut_uitoggletool_OffCallback(hObject, eventdata, handles)
% hObject    handle to zoomOut_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom off
handles.synapseLocator_figure.UserData.zoomH = [];

return

% --------------------------------------------------------------------
function zoomOut_uitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to zoomOut_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

return

% --------------------------------------------------------------------
function zoom_postcallback(obj, evd, handles)
obj.UserData.zoomXLim = evd.Axes.XLim;
obj.UserData.zoomYLim = evd.Axes.YLim;

% Simply click zLevel slider!
programmatic_zLevel(handles)

return


function resize_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to resize_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Deactivate zoom in or zoom out button!
zoom(handles.image_axes, 'off')
handles.synapseLocator_figure.UserData.zoomH = [];

% Reset image to full size!
handles.displayChannel_uibuttongroup.SelectedObject.String;

imSize = size(handles.synapseLocator_figure.UserData.sLobj.data.(handles.displayChannel_uibuttongroup.SelectedObject.String));

set(handles.image_axes, 'XLim', [0.5, imSize(1) + 0.5], 'YLim', [0.5, imSize(2) + 0.5])

% Clear zoom range!
handles.synapseLocator_figure.UserData.zoomXLim = [];
handles.synapseLocator_figure.UserData.zoomYLim = [];

% Clear image intensity settings!
handles.synapseLocator_figure.UserData.imageIntMin = 0;
handles.synapseLocator_figure.UserData.imageIntMax = 1;
handles.minIntensityG_edit.String = num2str(0);
handles.maxIntensityG_edit.String = num2str(1);
handles.minIntensityR_edit.String = num2str(0);
handles.maxIntensityR_edit.String = num2str(1);

% Simply click zLevel slider!
programmatic_zLevel(handles)

return

%%
% Start processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.synapseLocator_figure.Pointer = 'watch';

notify(handles.synapseLocator_figure.UserData.sLobj, 'run', 'all')
handles.synapseLocator_figure.Pointer = 'arrow';

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    % Oooops!
else
    % Changed parameters seen and accepted!
    changedParameter_accepted(handles)
    
    handles.statusText_text.String = '';
    
    % Simply click zLevel slider!
    programmatic_zLevel(handles)
end

return

% --- Executes on button press in runElastix_pushbutton.
function runElastix_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runElastix_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.synapseLocator_figure.Pointer = 'watch';

notify(handles.synapseLocator_figure.UserData.sLobj, 'run', 'elastix')
handles.synapseLocator_figure.Pointer = 'arrow';

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    % Oooops!
else
    % Changed parameters seen and accepted!
    changedParameter_accepted(handles)
    
    handles.statusText_text.String = '';
    
    % Simply click zLevel slider!
    programmatic_zLevel(handles)
end

return

% --- Executes on button press in runLocator_pushbutton.
function runLocator_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runLocator_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.synapseLocator_figure.UserData.sLobj.register_CMD)
    % Ooooops!
    return
end

handles.synapseLocator_figure.Pointer = 'watch';

notify(handles.synapseLocator_figure.UserData.sLobj, 'run', 'locator')
handles.synapseLocator_figure.Pointer = 'arrow';

if isempty(handles.synapseLocator_figure.UserData.sLobj.data.G0)
    % Oooops!
else
    % Changed parameters seen and accepted!
    changedParameter_accepted(handles)
    
    handles.statusText_text.String = '';
    
    % Simply click zLevel slider!
    programmatic_zLevel(handles)
end

return


%%
% Show/save output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveResults_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveResults_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save detected spots info to file!
handles.synapseLocator_figure.Pointer = 'watch';
notify(handles.synapseLocator_figure.UserData.sLobj, 'saveResults')
handles.synapseLocator_figure.Pointer = 'arrow';

return

%% 
% Track param changes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initialTransformParamsChanged(handles, varargin)

handles.synapseLocator_figure.UserData.sLobj.internalStuff.initialTransformParamsChanged = 1;
handles.parameter_togglebutton.BackgroundColor = [1.0, 0, 0];

return

function preProParamsChanged(handles, varargin)

handles.synapseLocator_figure.UserData.sLobj.internalStuff.preProParamsChanged = 1;
handles.parameter_togglebutton.BackgroundColor = [1.0, 0.25, 0];

return

function elastixParamsChanged(handles, varargin)

handles.synapseLocator_figure.UserData.sLobj.internalStuff.elastixParamsChanged = 1;
handles.parameter_togglebutton.BackgroundColor = [1.0, 0.5, 0];

return

function locatorParamsChanged(handles, varargin)

handles.synapseLocator_figure.UserData.sLobj.internalStuff.locatorParamsChanged = 1;
handles.parameter_togglebutton.BackgroundColor = [1.0, 1.0, 0];

return

function changedParameter_accepted(handles, varargin)
% Indicate that parameter were changed and figure update is needed!

handles.parameter_togglebutton.BackgroundColor = [1.0, 0.95, 0.95];

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compositeTif_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to compositeTif_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of compositeTif_radiobutton

val = get(hObject, 'Value');
handles.synapseLocator_figure.UserData.sLobj.compositeTif = val;

return

function transformRawData_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to transformRawData_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of transformRawData_radiobutton

val = get(hObject, 'Value');
handles.synapseLocator_figure.UserData.sLobj.transformRawData = val;

elastixParamsChanged(handles)

return

% --- Executes on button press in sum2_radiobutton.
function sum2_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to sum2_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sum2_radiobutton

val = get(hObject, 'Value');
handles.synapseLocator_figure.UserData.sLobj.sum2 = val;

elastixParamsChanged(handles)

return

% --- Executes on button press in upsampling_radiobutton.
function upsampling_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to upsampling_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of upsampling_radiobutton

val = get(hObject, 'Value');
handles.synapseLocator_figure.UserData.sLobj.upsampling = val;

preProParamsChanged(handles)

return






