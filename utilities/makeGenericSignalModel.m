function makeGenericSignalModel(obj)
%Make a generic signal model from existing "SL_genericSpotModel_s"!
% 
%   Run complete analysis of simple synthetic stack. Save model as
%   SL_genericSpotMode_s.
%   Get obj from active SynapseLocator (sL=get(findobj('Name', 'Synapse Locator'), 'UserData'); sLobj=sL.sLobj;)
%   Call makeGenericSignalModel(sLobj)
% 
%   Restart SynapseLocator
% 

obj.featureNames_signalChannel

% Get matching attributes from spine train data set!
ft_idx = cellfun(@(x) find(strcmp(obj.featureNames, strrep(x, '_SignalChannel', ''))), obj.featureNames_signalChannel, 'Uni', 0);
ft_idx = cat(1, ft_idx{:})';

modelData = obj.data.spotModel_data(:,[ft_idx, end]);
attributes = obj.featureNames(ft_idx);
relation = 'spot finder signal features';
labels = modelData(:,end); % Random class labels
trainData = matlab2weka(relation, attributes, modelData(:,1:end-1), labels);

% Train a Random Forest with specific options
signalModel = wekaTrainModel(trainData, 'trees.RandomForest', '-I 1000 -K 0 -S 123 -depth 25 -N 0 -M 0 -V 1e-3 -B -U -O -store-out-of-bag-predictions -output-out-of-bag-complexity-statistics -attribute-importance -output-debug-info');
signalModel %#ok<NOPRT>
% Classify data (input data)
[signal_predicted_, signal_classProbs_, ~] = wekaClassify(trainData, signalModel); %#ok<ASGLU>
tabulate(signal_predicted_)


% Save Model!
wekaSaveModel(fullfile(obj.synapseLocatorFolder, obj.wekaModelsFolder, 'SL_genericSignalModel_s.model'), signalModel);
% Save dataset!
wekaSaveData(fullfile(obj.synapseLocatorFolder, obj.wekaModelsFolder, 'SL_genericSignalModel_s_Data.csv'), trainData, 'CSV');

return

