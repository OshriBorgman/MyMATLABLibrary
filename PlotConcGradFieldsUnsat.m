function [fC, fG] = PlotConcGradFieldsUnsat(CField, GField, plotForPaper,...
    C, G, Pe, frIdx, delT0, t_a, pixLen,...
    advLengthScale, thrLenScale, Cmax, XXg, YYg, analyzImgFold2C,...
    analyzImgFold2G, bl_to_rd_diver_cmap, gradColMap, grainMask, visPlot, ...
    frontPlot, porosity, DeltaFd, lambda)

% PLOT CONCENTRATION AND GRADIENT FIELDS This function plots the various
% formats of concentration and gradient fields

% INPUT FLAGS
% CField - Plot the basic concentration field (fC)
% CFieldLine - Plot the basic concentration field with the advected line (fC2)
% CFieldNorm - Plot the normalized concentration field (fC3)
% GField - Plot the basic concentration gradient field (fG)
% GFieldLine - Plot the basic concentration gradient field with the advected line (fG2)
% mixVolPlot - Plot the mixing volume and its characteristics (fVm)
% plotForPaper - Plot with styling for a paper

% UPDATES


% % Fix the y-values of the interface image
% YYg = YYg+4;

if visPlot
    plotVisOpt = 'on';
else
    plotVisOpt = 'off';
end

if CField
    CC = C/Cmax;
% %     Include if I want to hide the pores outside the mixing zone
%     CC(C<0.02) = 0.02;
    CC(~grainMask) = 0;
    fC = PlotFieldImage(CC);
    hold on
    axC = gca;
    options = {bl_to_rd_diver_cmap, '$C $', plotVisOpt};
    setupFigForDisplay(fC, axC, options, Pe, frIdx, ...
        delT0, t_a, C, pixLen, advLengthScale, porosity, DeltaFd, lambda)    
    
    figTypeName = 'C_field';
    
    if frontPlot
        plot(XXg,YYg,'.', "Color", 'k', "MarkerSize", 2)
    end
    
    if plotForPaper
        saveas(fC, fullfile(analyzImgFold2C, 'svg', [sprintf('%s_fr_%03d', ...
            figTypeName, frIdx) '.svg']))
%         saveas(fC, fullfile(analyzImgFold2C, 'fig', [sprintf('%s_Pe=%3.0f_tau=%2.1f_fr_%03d', ...
%             figTypeName, PeAll(file_i), (frID-fr0+1)*delT0/t_a, frIdx) '.fig']))
        frame = getframe(axC);
        imwrite(frame.cdata, bl_to_rd_diver_cmap, fullfile(analyzImgFold2C, 'png', ...
            sprintf('%s_fr_%03d.png', figTypeName, frIdx)), 'png')
    end
    
else
    fC = [];
    
end

% Plot the gradients
if GField
    % fG = figure;
    GG = G;
%     %     Include if I want to hide the pores outside the mixing zone
%     GG(G<200) = 200;
    GG(~grainMask) = 0;
    fG = PlotFieldImage(GG./Cmax*thrLenScale);
    hold on
    axG = gca;
    colormap(gradColMap)
    % caxis([0 3.5e4])
    options = {gradColMap, '$\nabla C $', plotVisOpt};
    setupGradFigForDisplay(fG, axG, options, Pe, frIdx, ...
        delT0, t_a, C, pixLen, advLengthScale, porosity, DeltaFd, lambda)
    
    figTypeName = 'G_field';
    
%     if frontPlot
%         plot(XXg,YYg,'.', "Color", 'k', "MarkerSize", 2)
%     end
    
    if plotForPaper
        saveas(fG, fullfile(analyzImgFold2G, 'svg', [sprintf('%s_fr_%03d', ...
            figTypeName, frIdx) '.svg']))
%         saveas(fG, fullfile(analyzImgFold2G, 'fig', [sprintf('%s_Pe=%3.0f_tau=%2.1f_fr_%03d', ...
%             figTypeName, PeAll(file_i), (frID-fr0+1)*delT0/t_a, frIdx) '.fig']))
        frame = getframe(axG);
        imwrite(frame.cdata, bl_to_rd_diver_cmap, fullfile(analyzImgFold2G, 'png', ...
            sprintf('%s_fr_%03d.png', figTypeName, frIdx)), 'png')
    end
else 
    fG = [];
end

function setupFigForDisplay(figName, figAx, options, Pe, frIdx, ...
    delT0, t_a, Cshow, pixLen, lengthScale, porosity, DeltaFd, lambda)
% options:
% 1 - the name of the color map to use
% 2 - the legend on the colorbar
% 3 - visible on or off
figAx.Title.String = ...
    sprintf('$\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g; Pe = %4.0f; $\\tau$ = %2.1f', ...
    porosity, DeltaFd, lambda, Pe, frIdx*delT0/t_a);
figAx.XTick = 0:round(20*lengthScale/pixLen):size(Cshow, 2);
figAx.YTick = 0:round(20*lengthScale/pixLen):size(Cshow, 1);
figAx.XTickLabel = 0:20:size(Cshow, 2)*pixLen/lengthScale;
figAx.YTickLabel = 0:20:size(Cshow, 1)*pixLen/lengthScale;
figAx.TickDir = 'out';
figAx.YDir = "normal";
axis equal tight
figAx.YLim = [0 size(Cshow, 1)];
figAx.XLim = [0 size(Cshow, 2)];
box off
% axis off
figAx.XLabel.String = 'x/$\lambda$';
figAx.YLabel.String = 'y/$\lambda$';
% figAx.XLabel.String = 'x/$\overline{d_G}$';
% figAx.YLabel.String = 'y/$\overline{d_G}$';
% colormap(hot)%(1-hot)
colormap(options{1})
figCBar = colorbar;
% c.Limits = [0 maxGrad(maxGradIdx)];
figCBar.Limits = [0 1];
% c.Label.String = '$\nabla C$ [mg L$^{-1}$ m$^{-1}$]';
% c.Label.String = '$\nabla C \lambda / C_\mathrm{max}$';
figCBar.Label.Interpreter = "latex";
figCBar.Label.String = options{2};
figCBar.TickDirection = "out";
figCBar.FontSize = 16;
% caxis([0 maxGrad(maxGradIdx)])
caxis([0 1])
figName.Visible = options{3};
figAx.Title.String = [];
figAx.FontSize = 16;
% figName.Units = 'normalized';
% figName.Position = [0 0 1 1];
figName.Renderer = "painters";
return

function setupGradFigForDisplay(figName, figAx, options, Pe, frIdx, ...
    delT0, t_a, Cshow, pixLen, lengthScale, porosity, DeltaFd, lambda)
% options:
% 1 - the name of the color map to use
% 2 - the legend on the colorbar
% 3 - visible on or off
figAx.Title.String = ...
    sprintf('$\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g; Pe = %4.0f; $\\tau$ = %2.1f', ...
    porosity, DeltaFd, lambda, Pe, frIdx*delT0/t_a);
figAx.XTick = 0:round(20*lengthScale/pixLen):size(Cshow, 2);
figAx.XTickLabel = 0:20:size(Cshow, 2)*pixLen/lengthScale;
figAx.YTick = 0:round(20*lengthScale/pixLen):size(Cshow, 1);
figAx.YTickLabel = 0:20:size(Cshow, 1)*pixLen/lengthScale;
figAx.TickDir = 'out';
figAx.YDir = "normal";
axis equal tight
figAx.YLim = [0 size(Cshow, 1)];
figAx.XLim = [0 size(Cshow, 2)];
box off
% axis off
figAx.XLabel.String = 'x/$\lambda$';
figAx.YLabel.String = 'y/$\lambda$';
% figAx.XLabel.String = 'x/$\overline{d_G}$';
% figAx.YLabel.String = 'y/$\overline{d_G}$';
colormap(options{1})
figCBar = colorbar;
% c.Limits = [0 maxGrad(maxGradIdx)];
% c.Label.String = '$\nabla C$ [mg L$^{-1}$ m$^{-1}$]';
% c.Label.String = '$\nabla C \lambda / C_\mathrm{max}$';
figCBar.Label.Interpreter = "latex";
figCBar.Label.String = options{2};
figCBar.TickDirection = "out";
figCBar.FontSize = 16;
% caxis([0 maxGrad(maxGradIdx)])
caxis([0 500])
figCBar.Limits = [0 500];
figName.Visible = options{3};
figAx.Title.String = [];
figAx.Title.Interpreter = 'latex';
figAx.FontSize = 16;
% figName.Units = 'normalized';
% figName.Position = [0 0 1 1];
figName.Renderer = "painters";
return




return

