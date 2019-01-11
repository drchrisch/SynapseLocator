function summaryPlots(summary, dRGx, dRGxThreshold)
%summaryPlots produces histograms of spot and signal intensities

%
% MATLAB Version: 9.1.0.441655 (R2016b)
% MATLAB Version: 9.5.0.944444 (R2018b)
%
% drchrisch@gmail.com
%
% cs12dec2018
%


delete(findobj('-regexp', 'Name', 'Spot Intensity Overview'))
delete(findobj('-regexp', 'Name', 'Spot Intensity Overview II'))
delete(findobj('-regexp', 'Name', 'Spot Intensity Overview III'))

if isempty(summary.Spot_ID)
    return
end

% Show intensity values (sum of voxels for every detected spot)!
figure('Name', 'Spot Intensity Overview', 'NumberTitle', 'off', 'Position', [300 200 800 500], 'Units', 'pixels')
axH1 = subplot(2,2,1);
h1 = histogram(log10(summary.G0_max), 20);
h1.Normalization = 'probability';
title('green intensity (pre)')
xlabel('log10 (g max)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
ylabel('Probability [0, 1]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
axH3 = subplot(2,2,3);
h3 = histogram(log10(summary.G1_max), 20);
h3.Normalization = 'probability';
title('green intensity (post)')
xlabel('log10 (g max)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
ylabel('Probability [0, 1]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
axH2 = subplot(2,2,2);
h2 = histogram(log10(summary.R0_max), 20);
h2.Normalization = 'probability';
title('red intensity (pre)')
xlabel('log10 (r max)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
ylabel('Probability [0, 1]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
axH4 = subplot(2,2,4);
h4 = histogram(log10(summary.R1_max), 20);
h4.Normalization = 'probability';
title('red intensity (post)')
xlabel('log10 (r max)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
ylabel('Probability [0, 1]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1])
set(gca, 'FontSize', 10, 'FontWeight', 'bold')

axH1.XLim = [min(log10([summary.G0_max; summary.G1_max])), max(log10([summary.G0_max; summary.G1_max]))] .* [0.9, 1.1];
axH3.XLim = [min(log10([summary.G0_max; summary.G1_max])), max(log10([summary.G0_max; summary.G1_max]))] .* [0.9, 1.1];
axH2.XLim = [min(log10([summary.R0_max; summary.R1_max])), max(log10([summary.R0_max; summary.R1_max]))] .* [0.9, 1.1];
axH4.XLim = [min(log10([summary.R0_max; summary.R1_max])), max(log10([summary.R0_max; summary.R1_max]))] .* [0.9, 1.1];
h1.FaceColor = [0,1,0]; h1.EdgeColor = [0,0,0];
h3.FaceColor = [0,1,0]; h3.EdgeColor = [0,0,0];
h2.FaceColor = [1,0,0]; h2.EdgeColor = [0,0,0];
h4.FaceColor = [1,0,0]; h4.EdgeColor = [0,0,0];
h1.BinWidth = 0.1; h3.BinWidth = 0.1;
h2.BinWidth = 0.1; h4.BinWidth = 0.1;

linkaxes([axH1, axH3], 'x')
linkaxes([axH2, axH4], 'x')



figure('Name', 'Spot Intensity Overview II', 'NumberTitle', 'off', 'Position', [400 200 800 500], 'Units', 'pixels')
axH1 = subplot(2,2,1); %#ok<NASGU>
scatter(summary.rg_pre, summary.rg_post, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8)
title('R/G post vs. R/G pre', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
xlabel('R/G pre', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
ylabel('R/G post', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
grid on; box on
axH2 = subplot(2,2,2);
scatter(summary.G0_max_norm, summary.r_delta_norm, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8)
title('delta R vs. G1', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
ylabel('delta R', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
grid on; box on

switch dRGx
    case 'dR/G0'
        axH3 = subplot(2,2,3);
        scatter(summary.G0_max_norm, summary.rDelta_g0, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8)
        title('dR/G0 vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
        xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        ylabel('dR/G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        set(gca, 'FontSize', 10, 'FontWeight', 'bold')
        grid on; box on
    case 'dR/Gsum'
        axH3 = subplot(2,2,3);
        scatter(summary.G1_max_norm, summary.rDelta_gSum, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8)
        title('dR/Gsum vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
        xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        ylabel('dR/Gsum', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        set(gca, 'FontSize', 10, 'FontWeight', 'bold')
        grid on; box on
end
axH4 = subplot(2,2,4);
scatter(summary.G0_max_norm, summary.r_factor, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8)
title('dR/R1 vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
ylabel('dR/R1', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
grid on; box on
linkaxes([axH2, axH3, axH4], 'x')


% Show 'signal quality' plots!
switch dRGx
    case 'dR/G0'
        tmp_Idx = gt(summary.rDelta_g0, dRGxThreshold) & gt(summary.r_delta, 0);
    case 'dR/Gsum'
        tmp_Idx = gt(summary.rDelta_gSum, dRGxThreshold) & gt(summary.r_delta, 0);
end

figure('Name', 'Spot Intensity Overview III', 'NumberTitle', 'off', 'Position', [500 200 800 500], 'Units', 'pixels')
axH1 = subplot(2,2,1); %#ok<NASGU>
scatter(summary.rg_pre, summary.rg_post, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5)
hold on
scatter(summary.rg_pre(tmp_Idx), summary.rg_post(tmp_Idx), 10, 'o', 'filled', 'MarkerFaceColor', [1.0, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1)
hold off
title('R/G post vs. R/G pre', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
xlabel('R/G pre', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
ylabel('R/G post', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
grid on; box on
axH2 = subplot(2,2,2);
scatter(summary.G0_max_norm, summary.r_delta_norm, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5)
hold on
scatter(summary.G0_max_norm(tmp_Idx), summary.r_delta_norm(tmp_Idx), 10, 'o', 'filled', 'MarkerFaceColor', [1, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1)
hold off
title('delta R vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
ylabel('delta R', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
grid on; box on
switch dRGx
    case 'dR/G0'
        axH3 = subplot(2,2,3);
        scatter(summary.G0_max_norm, summary.rDelta_g0, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5)
        hold on
        scatter(summary.G0_max_norm(tmp_Idx), summary.rDelta_g0(tmp_Idx), 10, 'o', 'filled', 'MarkerFaceColor', [1, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1)
        hold off
        title('dR/G0 vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
        xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        ylabel('dR/G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        set(gca, 'FontSize', 10, 'FontWeight', 'bold')
        grid on; box on
    case 'dR/Gsum'
        axH3 = subplot(2,2,3);
        scatter(summary.G0_max_norm, summary.rDelta_gSum, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5)
        hold on
        scatter(summary.G0_max_norm(tmp_Idx), summary.rDelta_gSum(tmp_Idx), 10, 'o', 'filled', 'MarkerFaceColor', [1, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1)
        hold off
        title('dR/Gsum vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
        xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        ylabel('dR/Gsum', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
        set(gca, 'FontSize', 10, 'FontWeight', 'bold')
        grid on; box on
end

axH4 = subplot(2,2,4);
scatter(summary.G0_max_norm, summary.r_factor, 50, 'o', 'filled', 'MarkerFaceColor', [0.1, 0.6, 1.0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.8, 'MarkerFaceAlpha', 0.5)
hold on
scatter(summary.G0_max_norm(tmp_Idx), summary.r_factor(tmp_Idx), 10, 'o', 'filled', 'MarkerFaceColor', [1, 0, 0], 'MarkerEdgeColor', [0 0 0], 'LineWidth', 0.1)
hold off
title('dR/R1 vs. G0', 'FontSize', 10, 'FontWeight', 'bold', 'interpreter', 'none')
xlabel('G0', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
ylabel('dR/R1', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1], 'interpreter', 'none')
set(gca, 'FontSize', 10, 'FontWeight', 'bold')
grid on; box on
linkaxes([axH2, axH3, axH4], 'x')

return
