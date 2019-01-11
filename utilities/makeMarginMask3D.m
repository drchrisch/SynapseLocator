function marginMask = makeMarginMask3D(fieldSize, margins)
% Get a mask to blank some areas of a stack!

% MATLAB Version 7.13.0.564 (R2011b) -> MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs10sep2018
% cs12dec2018
%

if lt(numel(margins), 3)
    margins(1:3) = margins;
end

marginMask = zeros(fieldSize);

marginVal = fix((fieldSize .* (1 - margins)) / 2);

marginMask(marginVal(1) + 1:end - marginVal(1), marginVal(2) + 1:end - marginVal(2), marginVal(3) + 1:end - marginVal(3)) = 1;

end