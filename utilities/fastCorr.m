function [coef, p] = fastCorr(A, B)
%FASTCORR - Fast calculation of Pearson correlation coefficient
%
% Code modified to return Person correlation only!
% For original code see:
% Oleksandr Frei (2020). nancorr (https://www.mathworks.com/matlabcentral/fileexchange/71893-nancorr), MATLAB Central File Exchange. Retrieved January 8, 2020.
%
% This function is faster than Matlab's corr function for vectors up to
% around N=1e4.
% 
%  coef = NANCORR(A, B) is equivalent to
%  coef = corr(A, B, 'rows','pairwise'),
%  but NANCORR works much faster.
%
%  [coef] = NANCORR(A, B)
%  INPUT:
%    A, B - input matrices, single or double, with equal number of rows
%
%  OUTPUT:
%    coef - matrix of Pearson correlation coefficients
%

% code one of the formulas from https://en.wikipedia.org/wiki/Pearson_correlation_coefficient
% this procedure might be numericaly unstable for large values,
% it might be reasonable to center each column before calling nancorr.
% xy = A' * B;          % sum x_i y_i
xy = dot(A, B);

n = numel(A);        % number of items defined both in x and y

% mean values in x, calculated across items defined both in x and y
mx = sum(A) / n;
% mean values in y, calculated across items defined both in x and y
my = sum(B) / n;

% sum x^2_i, calculated across items defined both in x and y
x2 = dot(A, A);
% sum y^2_i, calculated across items defined both in x and y
y2 = dot(B, B);

sx   = sqrt(x2 - n .* (mx.^2));  % sx, sy - standard deviations
sy   = sqrt(y2 - n .* (my.^2));

coef = (xy - n .* mx .* my) ./ (sx .* sy);      % correlation coefficient
t    = coef .* sqrt((n - 2) ./ (1 - coef.^2));  % t-test statistic

p = 2*tcdf(-abs(t), n - 2); % pvalue
% p = [];
end