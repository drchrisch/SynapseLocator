function varargout = dftregistration3D(varargin)
% Registers the dataMoved array to the dataFixed array and reports the correction values. The default is to calculate
% shift values with 0.1 pixels resolution along each dimension.
% 
%
% Input data should have same size (at least in x and y). A single 2D image
% can be registered to a 3D stack! Dimensions of input data should be even
% numbers!
% The function accepts both 'raw' data and arrays that are already fft type! When subbmitting 'raw' data it might be
% helpful to set a filter for better performance. The area to be useg for registration can be narrowed down by settting the
% 'coreField' parameter to some value < 1. When submitting data that are fft type it is a bit against the logic to ask
% for filtering or use of gradient at that stage. There is one special case, where the dataFixed array is used multiple
% times and only a single 2D array is submitted. Here, the option 'FHImager' must be set to 1!
% Option 'subpixel' sets the fractional precision for calculating correction values!
% It should be kept in mind that increasing the precision comes with an almost exponential increase in calculation time!
% Avoid precision values beyond 100!
% The correction values are obtained from the maximum of the correlation
% matrix. For some images it might be better to get the position as average
% of the 5 most intense positions. Use option.robust = 1.
% 
% Calls makeMarginMask3D.m and functions from KronProd
% 
% Option 'gradient' lets the function work on the gradient of the input data!
% Default settings (and possible values) are: 
%           options.FHImager = 0; {0, 1}
%           options.filter = '';  {'', 'gaussian', 'median', 'imsmooth'}
%           options.gradient = 0; {0, 1}
%           options.subpixel = 1; {1...100}
%           options.coreField = 0.9; {0.1...1.0}
%           options.robust = 1; {0, 1}
%             
% 
% Usage: [correction_coarse, correction_fine, error] = dftregistration3D(dataFixed, dataMoved {, options});
%
%
% MATLAB Version 7.13.0.564 (R2011b) -> MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs10sep2018
% cs12dec2018
%
%

dbstop if error


% Default values for options!
options.FHImager = 0;
options.filter = ''; % {'', 'gaussian', 'median', 'imsmooth'}
options.gradient = 0;
options.subpixel = 1;
options.coreField = 0.8;
options.robust = 1;
options.imsmoothFactor = .5;



try
    % Check data!
    dataFixed = varargin{1};
    dataMoved = varargin{2};
    
    % Check input array dimension!
    sizeFixed = size(dataFixed);
    sizeMoved = size(dataMoved);
    if ne(sizeFixed(1:2), sizeMoved(1:2))
        errordlg('Input arrays must have same xy-size!');
        return
    end
catch ME
    msg = ME.message;
    disp(msg)
    disp(['Wrong data size!' filename ]);
end

try
    % Get options!
    if eq(nargin, 3)
        options_tmp = varargin{3};
        if isfield(options_tmp, 'FHImager')
            options.FHImager = options_tmp.FHImager;
        end
        if isfield(options_tmp, 'filter')
            options.filter = options_tmp.filter;
        end
        if isfield(options_tmp, 'gradient')
            options.gradient = options_tmp.gradient;
        end
        if isfield(options_tmp, 'subpixel')
            options.subpixel = options_tmp.subpixel;
        end
        if isfield(options_tmp, 'coreField')
            options.coreField = options_tmp.coreField;
        end
    end
catch ME
    msg = ME.message;
    disp(msg)
    disp(['Options error!' filename ]);
end

try
    % Check for options!
    % Check for FHImager processing! Requires special input!
    if options.FHImager
        filterType = options.filter;
        switch filterType
            case 'median'
                dataMoved = medfilt2(dataMoved, [5, 5], 'symmetric');
            case 'gaussian'
                dataMoved = imfilter(dataMoved, fspecial('gaussian', [9, 9], 2), 'replicate');
            case 'imsmooth'
                dataMoved = imsmooth(dataMoved, options.imsmoothFactor);
        end
        
        if options.gradient
            dataMoved = gradient(dataMoved);
        end
        
        % Create new dataMoved array and place single image at z-center!
        fftSize = sizeFixed;
        dataMoved_tmp = zeros(fftSize);
        dataMoved_tmp(:,:,ceil(fftSize(3)/2)) = dataMoved;
        
        if ne(options.coreField, 1)
            marginMask = makeMarginMask3D(fftSize, options.coreField);
            dataFixed = dataFixed .* marginMask;
            dataMoved_tmp = dataMoved_tmp .* marginMask;
        end
        
        % Do fft!
        dataFixed_fft = dataFixed;
        dataMoved_fft = fftn(dataMoved_tmp, fftSize);
        
    else
        if any([~isempty(options.filter), ne(options.coreField, 1)])
            if ~isreal(dataFixed)
                dataFixed = ifftn(dataFixed);
            end
            if ~isreal(dataMoved)
                dataMoved = ifftn(dataMoved);
            end
            
            % Smooth image if requested! (Option is only relevant for real data, pre fft)
            filterType = options.filter;
            switch filterType
                case 'median'
                    dataFixed = arrayfun(@(x) medfilt2(dataFixed(:,:,x), [5, 5], 'symmetric'), 1:size(dataFixed, 3), 'Uni', 0);
                    dataFixed = cat(3,dataFixed{:});
                    dataMoved = arrayfun(@(x) medfilt2(dataMoved(:,:,x), [5, 5], 'symmetric'), 1:size(dataMoved, 3), 'Uni', 0);
                    dataMoved = cat(3,dataMoved{:});
                case 'gaussian'
                    dataFixed = arrayfun(@(x) imfilter(dataFixed(:,:,x), fspecial('gaussian', [5, 5], 1), 'replicate'), 1:size(dataFixed, 3), 'Uni', 0);
                    dataFixed = cat(3,dataFixed{:});
                    dataMoved = arrayfun(@(x) imfilter(dataMoved(:,:,x), fspecial('gaussian', [5, 5], 1), 'replicate'), 1:size(dataMoved, 3), 'Uni', 0);
                    dataMoved = cat(3,dataMoved{:});
                case 'imsmooth'
%                     dataFixed = arrayfun(@(x) imsmooth(dataFixed(:,:,x), options.imsmoothFactor), 1:size(dataFixed, 3), 'Uni', 0);
%                     dataFixed = cat(3,dataFixed{:});
%                     dataMoved = arrayfun(@(x) imsmooth(dataMoved(:,:,x), options.imsmoothFactor), 1:size(dataMoved, 3), 'Uni', 0);
%                     dataMoved = cat(3,dataMoved{:});
                    dataFixed = imsmooth(dataFixed, options.imsmoothFactor * [1, 1, 0.5]);
                    dataMoved = imsmooth(dataMoved, options.imsmoothFactor * [1, 1, 0.5]);
            end
            
            if options.gradient
                % Distinguish between 2D and 3D stacks!
                if eq(numel(sizeMoved),2)
                    dataFixed = arrayfun(@(x) gradient(dataFixed(:,:,x)), 1:size(dataFixed, 3), 'Uni', 0);
                    dataFixed = cat(3,dataFixed{:});
                else
                    dataFixed = gradient(dataFixed);
                end
                dataMoved = gradient(dataMoved);
            end
            
            % Check if only core region of stack should be used!
            % Distinguish between 2D and 3D stacks!
            if eq(numel(sizeFixed),3)
                marginMask = makeMarginMask3D(sizeFixed, options.coreField);
                dataFixed = dataFixed .* marginMask;
            elseif eq(numel(sizeFixed),2)
                marginMask = makeMarginMask3D([sizeFixed, 1], options.coreField);
                dataFixed = dataFixed .* marginMask;
            end
            if eq(numel(sizeMoved),3)
                marginMask = makeMarginMask3D(sizeMoved, options.coreField);
                dataMoved = dataMoved .* marginMask;
            elseif eq(numel(sizeMoved),2)
                marginMask = makeMarginMask3D([sizeMoved, 1], options.coreField);
                dataMoved = dataMoved .* marginMask;
            end
        end
    end
catch ME
    msg = ME.message;
    disp(msg)
    disp(['Apply options error!' filename ]);
end
        
% Check for mixed 2D/3D input!
preShift = 0;
if eq(numel(sizeMoved),2)
    % Got stack and single slice image as input!
    sizeMoved(3) = 1;
    preShift = floor(sizeFixed(3)/2);
end

% Do fft now!
if options.FHImager
%     fftSize = max(sizeFixed, sizeMoved);
%     dataFixed_fft = dataFixed;
%     dataMoved_tmp = zeros(fftSize);
%     dataMoved_tmp(:,:,ceil(sizeFixed(3)/2)) = dataMoved;
%     dataMoved_fft = fftn(dataMoved_tmp, fftSize);
else
    fftSize = max(sizeFixed, sizeMoved);
    modIdx = logical(mod(fftSize,2));
    fftSize(modIdx) = fftSize(modIdx) + 1;
    if isreal(dataFixed)
        dataFixed_fft = fftn(dataFixed, fftSize);
    else
        dataFixed_fft = dataFixed;
    end
    if isreal(dataMoved)
        dataMoved_fft = fftn(dataMoved, fftSize);
    else
        dataMoved_fft = dataMoved;
    end
end

try
    % Get correlation at 1 pixel resolution!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % dataCorrelation = fftshift(real(ifftn(dataFixed_fft .* conj(dataMoved_fft))));
    dataCorrelation_raw = dataFixed_fft .* conj(dataMoved_fft);
    dataCorrelation = fftshift(real(ifftn(dataCorrelation_raw)));
    
    if options.robust
        % Get average position of top correlated pixels!
        [dataCorrelationMax, ~] = max(dataCorrelation(:));
        corrValsTestNo = 5; % Test top 5 correlation values!
        tmpIdx = dataCorrelation(:) >= quantile(dataCorrelation(:), ((numel(dataCorrelation) - corrValsTestNo)/numel(dataCorrelation)));
        [maxX, maxY, maxZ] = ind2sub(size(dataCorrelation), find(tmpIdx));
        maxXYZ = [maxX, maxY, maxZ];

        if eq(sizeMoved(3), 1) % Got stack and single slice image as input!
            maxXYZ(:,3) = maxXYZ(:,3) + preShift;
            maxXYZ = bsxfun(@minus, (maxXYZ - 1), fftSize/2);
% 
%             maxXYZ(1:2) = bsxfun(@minus, (maxXYZ(1:2) - 1), fftSize(1:2)/2);
%             maxXYZ(:,3) = maxXYZ(:,3) - preShift - 1;
        else
            maxXYZ = bsxfun(@minus, (maxXYZ - 1), fftSize/2);
        end
%         maxXYZ(:,3) = maxXYZ(:,3) + preShift;
%         maxXYZ = bsxfun(@minus, (maxXYZ - 1), fftSize/2);
        maxXYZ = round(mean(maxXYZ,1));
        
%         tmpIdx = maxXYZ_sub >= dftshift;
%         maxXYZ_sub(tmpIdx) = (maxXYZ_sub(tmpIdx) - 1 - dftshift) / usfac;
%         maxXYZ_sub(~tmpIdx) = (maxXYZ_sub(~tmpIdx) - 1) / usfac;
%         maxXYZ_sub = mean(maxXYZ_sub,1);
% 
%         [~, Idx] = sort(dataCorrelation(:), 'descend');
%         corrValsTestNo = 10; % Test top 10 correlation values!
%         [maxX, maxY, maxZ] = ind2sub(fftSize, Idx(1:corrValsTestNo));
%         maxXYZ = [maxX, maxY, maxZ];
    else
        % Get position of top correlated pixel (single 'hit' version)!
        [dataCorrelationMax, Idx] = max(dataCorrelation(:));
        [maxX, maxY, maxZ] = ind2sub(fftSize, Idx);
        maxXYZ = [maxX, maxY, maxZ];
        if eq(sizeMoved(3), 1) % Got stack and single slice image as input!
            maxXYZ(1:2) = bsxfun(@minus, (maxXYZ(1:2) - 1), fftSize(1:2)/2);
            maxXYZ(:,3) = maxXYZ(:,3) - preShift - 1;
        else
            maxXYZ = bsxfun(@minus, (maxXYZ - 1), fftSize/2);
        end
    end
    correction_coarse = maxXYZ;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rfzero = sum(abs(dataFixed_fft(:)).^2)/prod(fftSize);
    rgzero = sum(abs(dataMoved_fft(:)).^2)/prod(fftSize);
    error = 1.0 - dataCorrelationMax.*conj(dataCorrelationMax)/(rgzero(1,1)*rfzero(1,1));
    error = sqrt(abs(error));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Run subpixel registration if required!
    if gt(options.subpixel, 1)
        usfac = options.subpixel;
        dftshift = fix(ceil(usfac*1.5)/2);

% %         % First upsample by a factor of 2 to obtain initial estimate
% %         % Embed Fourier data in a 2x larger array
% %         fftSize_up = 2 * fftSize;
% %         dataCorrelation_up = zeros(fftSize_up);
% %         dataCorrelation_up(fftSize(1)+1-fix(fftSize(1)/2):fftSize(1)+1+fix((fftSize(1)-1)/2),...
% %             fftSize(2)+1-fix(fftSize(2)/2):fftSize(2)+1+fix((fftSize(2)-1)/2),...
% %             fftSize(3)+1-fix(fftSize(3)/2):fftSize(3)+1+fix((fftSize(3)-1)/2)) = ...
% %             dataFixed_fft.*conj(dataMoved_fft);
% %         % Location of the peak!
% %         dataCorrelation_tmp = fftshift(real(ifftn(dataCorrelation_up)));
% %         [~, Idx_up] = max(dataCorrelation_tmp(:));
% %         [maxX_up, maxY_up, maxZ_up] = ind2sub(fftSize_up, Idx_up);
% %         maxXYZ_up = [maxX_up, maxY_up, maxZ_up];
% %         if eq(sizeMoved(3), 1) % Got stack and single slice image as input!
% %             maxXYZ_up(1:2) = bsxfun(@minus, (maxXYZ_up(1:2) - 1), fftSize_up(1:2)/2);
% %             maxXYZ_up(:,3) = maxXYZ_up(:,3) - 1  - preShift*2;
% %         else
% %             maxXYZ_up = bsxfun(@minus, (maxXYZ_up - 1), fftSize_up/2);
% %         end
% % 
% %         Qx = (1/fftSize_up(1)*usfac) * exp((-1i*2*pi/(fftSize_up(1)*usfac)) * ((maxXYZ_up(1)-dftshift):(maxXYZ_up(1)+dftshift))' * (0:(fftSize_up(1) - 1)) );
% %         Qy = (1/fftSize_up(2)*usfac) * exp((-1i*2*pi/(fftSize_up(2)*usfac)) * ((maxXYZ_up(2)-dftshift):(maxXYZ_up(2)+dftshift))' * (0:(fftSize_up(2) - 1)) );
% %         Qz = (1/fftSize_up(3)*usfac) * exp((-1i*2*pi/(fftSize_up(3)*usfac)) * ((maxXYZ_up(3)-dftshift):(maxXYZ_up(3)+dftshift))' * (0:(fftSize_up(3) - 1)) );
% %         Q = KronProd({Qx, Qy, Qz}, [1, 2, 3], fftSize_up);
% %         dataCorrelation_sub = abs(Q * dataCorrelation_up);
% % %         figure;for i=1:size(dataCorrelation_sub,3), imagesc(abs(dataCorrelation_sub(:,:,i))), pause(0.1), end
% %         [~, Idx_sub] = max(dataCorrelation_sub(:));
% %         [maxX_sup, maxY_sup, maxZ_sup] = ind2sub(size(dataCorrelation_sub), Idx_sub);        
% %         maxXYZ_sub = [maxX_sup, maxY_sup, maxZ_sup];
% %         maxXYZ_sub = bsxfun(@minus, (maxXYZ_sub - 1), dftshift) / usfac;
% %         correction_fine = maxXYZ_sub;

        

        Qx = (1/fftSize(1)*usfac) * exp((-1i*2*pi/(fftSize(1)*usfac)) * ((maxXYZ(1)-dftshift):(maxXYZ(1)+dftshift))' * (0:(fftSize(1) - 1)) );
        Qy = (1/fftSize(2)*usfac) * exp((-1i*2*pi/(fftSize(2)*usfac)) * ((maxXYZ(2)-dftshift):(maxXYZ(2)+dftshift))' * (0:(fftSize(2) - 1)) );
        Qz = (1/fftSize(3)*usfac) * exp((-1i*2*pi/(fftSize(3)*usfac)) * ((maxXYZ(3)-dftshift):(maxXYZ(3)+dftshift))' * (0:(fftSize(3) - 1)) );
        Q = KronProd({Qx, Qy, Qz}, [1, 2, 3], fftSize);
        dataCorrelation_sub = abs(Q * dataCorrelation_raw);
%         figure;for i=1:size(dataCorrelation_sub,3), imagesc(abs(dataCorrelation_sub(:,:,i))), pause(0.1), end

% %{
        % Get average position of top correlated pixels!
        corrValsTestNo = 5; % Test top 5 correlation values!
        tmpIdx = dataCorrelation_sub(:) >= quantile(dataCorrelation_sub(:), ((numel(dataCorrelation_sub) - corrValsTestNo)/numel(dataCorrelation_sub)));
        [maxX_sub, maxY_sub, maxZ_sub] = ind2sub(size(dataCorrelation_sub), find(tmpIdx));
        maxXYZ_sub = [maxX_sub, maxY_sub, maxZ_sub];
        tmpIdx = maxXYZ_sub >= dftshift;
        maxXYZ_sub(tmpIdx) = (maxXYZ_sub(tmpIdx) - 1 - dftshift) / usfac;
        maxXYZ_sub(~tmpIdx) = (maxXYZ_sub(~tmpIdx) - 1) / usfac;
        maxXYZ_sub = mean(maxXYZ_sub,1);
% %}
%{
        [~, Idx_sub] = max(dataCorrelation_sub(:));
        [maxX_sup, maxY_sup, maxZ_sup] = ind2sub(size(dataCorrelation_sub), Idx_sub);
        maxXYZ_sub = [maxX_sup, maxY_sup, maxZ_sup];
        tmpIdx = maxXYZ_sub >= dftshift;
        maxXYZ_sub(tmpIdx) = (maxXYZ_sub(tmpIdx) - 1 - dftshift) / usfac;
        maxXYZ_sub(~tmpIdx) = (maxXYZ_sub(~tmpIdx) - 1) / usfac;
%}
        correction_fine = maxXYZ_sub;
    else
        correction_fine = [0, 0, 0];
    end
    
    varargout{1} = correction_coarse;
    varargout{2} = correction_fine;
    varargout{3} = error;

catch ME
    msg = ME.message;
    disp(msg)
    disp(['FFT error!' filename ]);
end
