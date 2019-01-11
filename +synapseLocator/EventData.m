classdef EventData < event.EventData
    %EVENTDATA spot finder EventData class -- contains additional property spot finder variable supplied by spot finder event notifiers
    %
    % NOTES
    %   someData can be a structure, e.g. for cases where event notification includes 2 or more values to pass to listeners
    
    %
    % MATLAB Version: 9.1.0.441655 (R2016b)
    % MATLAB Version: 9.5.0.944444 (R2018b)
    %
    % drchrisch@gmail.com
    %
    % cs12dec2018
    %
    
    properties
        someData; % Spot finder-supplied event data
    end
    
    methods
        function obj = EventData(someData)
            if nargin
                obj.someData = someData;
            end
        end
    end
end

