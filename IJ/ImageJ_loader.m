function ImageJ_loader(IJ_exe)
% Sets up the classpath to Fiji/ImageJ!
% Add all libraries in jars/ and plugins/ to the classpath

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%


[IJ_dir, ~, ~] = fileparts(IJ_exe);


% Get the Java classpath
classpath = javaclasspath('-all');

% Switch off warning
warning_state = warning();
warning('off')

% Look for kind of 'weka-dev-3.9.1.jar' in fiji
wekas = dir(fullfile(IJ_dir, 'jars'));
wekas = cellfun(@(x) regexp(x, 'weka.*.jar$', 'match'), ({wekas.name}), 'Uni', 0); % looks for kind of 'weka-dev-3.9.1.jar' in fiji 
if ~any(cellfun(@(x) ~isempty(x), wekas))
    error('WEKALAB:wekaPathCheck:PathNotFound', 'Weka.jar not found!');
else
    % wekas = cell2mat(wekas{(cellfun(@(x) ~isempty(x), wekas))});
    % javaaddpath(fullfile(IJ_dir, 'jars', wekas), '-end');
	add_to_classpath(classpath, fullfile(IJ_dir, 'jars'));
	add_to_classpath(classpath, fullfile(IJ_dir, 'plugins'));

	% Set the Fiji directory (and plugins.dir which is not Fiji.app/plugins/)
	javaMethod('setProperty', 'java.lang.System', 'ij.dir', IJ_dir);
	javaMethod('setProperty', 'java.lang.System', 'plugins.dir', IJ_dir);
end
% Switch warning back to initial settings
warning(warning_state)

end

function add_to_classpath(classpath, directory)
% Get all .jar files in the directory

dirData = dir(directory);
dirIndex = [dirData.isdir];
jarlist = dir(fullfile(directory,'*.jar'));
path_= cell(0);
for i = 1:length(jarlist)
    %disp(jarlist(i).name);
    if not_yet_in_classpath(classpath, jarlist(i).name)
        path_{length(path_) + 1} = fullfile(directory,jarlist(i).name);
    end
end

% Add them to the classpath
if ~isempty(path_)
    javaaddpath(path_, '-end');
end

% Recurse over subdirectories
subDirs = {dirData(dirIndex).name};
validIndex = ~ismember(subDirs,{'.','..'});

for iDir = find(validIndex)
    nextDir = fullfile(directory,subDirs{iDir});
    add_to_classpath(classpath, nextDir);
end

end

function test = not_yet_in_classpath(classpath, filename)
% Test whether the library was already imported

expression = strcat([filesep filename '$']);
test = isempty(cell2mat(regexp(classpath, expression)));

end
