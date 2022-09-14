% bb2021.08.12 Make some plot to consolidate all the final penalty information. 
% RUN THIS FROM THE ROOT FOLDER OF THIS PROJECT, same folder as clusterLoopBig.m
clear allEachPenalty2Deep 

lineOrBar = 'line'; % brb2022.09.12 Might not work with "bar" anymore. 
showMeanPens = false; % Can plot mean of penalty reduction across components. 

% recalcOrder = false; % calculate the order of which variables did best at reducing penalty. 
for recalcOrder = [true, false]; % First, figure out the order to plot things left/right. Then actually plot. 

whichAnalyze = [1, 5, 11]; % datCompSpec index

datCompSpec = {...
    {1,1,'spec'},...
    {1,2,'spec'},...
    {1,3,'spec'},...
    {1,4,'spec'},...
    {2,1,'spec'},...
    {3,1,'spec'},...
    {1,1,'coh'},...
    {1,2,'coh'},...
    {1,3,'coh'},...
    {2,1,'coh'},... % Not positive if this is all of them. 
    {1,23,'spec'}... % Both horizontal 1 and 2. 
    };

symbolsScatter = {'o','+','*','.','x','_','|','s','d','^','v','>','<','p','h'}; 

datCompLabels = {'Z', 'H1', 'H2', 'P', ... % Uncorrected spec
    'Z corrected', 'Z tilt corrected',... % Corrected spec
    'Z-H1', 'Z-H2', 'Z-P', 'Z-P corrected', 'H'}; % Coherance

% labelsAllUnsort = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
%             'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
%             'OBS Design'; 'Seismometer'; 'Pressure Gauge'; 'Environment'; 'Experiment'};
labelsAllUnsort = load('labelsAll'); % Gets saved in clusterLoopBig.m
labelsAllUnsort = labelsAllUnsort.labelsAll; 

rmv3Lyr = logical([1 0 0 0 0 0 0 1 0 0 0 ]'); % Remove water depth and some other things. 
frstLyr = 8; % Determine order. Of hierarchy? 
scndLyr = 1; 
        
datCompSpec = datCompSpec(whichAnalyze); 
symbolsScatter = symbolsScatter(whichAnalyze); 
datCompLabels = datCompLabels(whichAnalyze); 


% This chooses which analysis to do. Loop through all analyses, or just do some. 
eachLayerDepth = [1,3]; % plot 3 layer deep first, since penalties are lower, and bars goes beneath 1 layer deep
eachDatComp = [1:size(datCompSpec,2)]; 
eachQuant = [1:length(labelsAllUnsort)];  
        
figure(70); clf; set(gcf, 'pos', [-1069 1452 702 257]); hold on; 
t = tiledlayout(1,2,'TileSpacing','tight','Padding','compact'); % Use tiled layout instead of subplot for tighter subplots. 
% cmap = jet(length(eachDatComp)); cmap = hsv(length(eachDatComp)); cmap = lines(length(eachDatComp)); cmap = colorcube(length(eachDatComp)); 
cmap = [ 48, 120, 0; 156, 0, 72; 255, 153, 0]./255; 

%%% Main plotting loop
for iLayerDepth = eachLayerDepth; % Do layer depths seperately. Easiest coding solution, since single or multiple layer analyses used the same figure windows, and were originally intended to run seperately. 
indLayerDepth = find(iLayerDepth == eachLayerDepth); 
allBar = []; % Holding some info for plotting through loop. 
legPlots = []; % Hold plot handles to add to legend. 
legPlotsLevel = []; % Hold plot handles to add to legend only showing dashed, dotted, etc. 

nexttile; hold on; 

for idatcomp = eachDatComp; % Loop through all combinations of datswitcs, seismometer component, and spectra/coherance. 
    % for idatcomp = [1:size(datcomp, 1)]; 
    % iLayerDepth = 3; idatcomp = 1; disp('Delete this line')
    thisDatCompSpec = datCompSpec{idatcomp}; 
    datswitch   = thisDatCompSpec{1}; 
    component   = thisDatCompSpec{2}; 
    coh_or_spec = thisDatCompSpec{3}; 

    finPenFile = sprintf('pen_results/penalties_%s_layerDepth%1.0f_datswitch%1.0f_component%1.0f.mat',...
        coh_or_spec, iLayerDepth, datswitch, component); % .mat file containing all penalty stuff, I think made with clusterLoopBig.m

    finPenData = load(finPenFile).finPenData; 
    penaltyUnClust = finPenData.penaltyUnClust; % Penalty before clustering
    eachPenalty = finPenData.eachPenalty; % Penalties after clustering
    eachPenalty = eachPenalty ./ penaltyUnClust .* 100; % normalize penalties to what it would be if they were not clustered
    eachPenalty = 100 - eachPenalty; % Converting to penalty reduction
        
    penaltySortPlot = [1:length(eachPenalty)]'; 
    if ~ recalcOrder; % Looping over recalcOrder = true and false. Have to find order of what has highest penalty reduction for determining order. After finding the order, make the plotting. 
        load(['penaltySortPlotDepth' num2str(iLayerDepth) '.mat']); % Need to run first time with recalcOrder True. Then you can run with recalcOrder false, and it displays things in the correct order. 
        if showMeanPens
            meanPenPlot = load(['meanPenPlot' num2str(iLayerDepth) '.mat']).meanPen(penaltySortPlot); % Get average accross components. 
            scatter([1:size(eachPenalty,1)]', meanPenPlot', 'k', '*', 'linewidth', 1);  % Plot average accross components. 
            sprintf('Average of all penalty reductions accross parameters first then components: %1.4f', nanmean(meanPenPlot))
        end
    end
    eachPenalty = eachPenalty(penaltySortPlot); 
    labelsAll = labelsAllUnsort(penaltySortPlot); 
   

    pltLineWidth = 2; 
    if iLayerDepth == 3; 
        % plot 2 deep penalty. 
        eachPenalty2Deep = finPenData.eachPenalty2Deep; 
        eachPenalty2Deep = 100-(eachPenalty2Deep ./ penaltyUnClust).*100; 
        eachPenalty2Deep = eachPenalty2Deep(penaltySortPlot); 
        eachPenalty(rmv3Lyr(penaltySortPlot)) = nan; % Have to keep the re-ordering rmv3Lyr here, or else it gets reordered 3 times. 
        eachPenalty2Deep(isnan(eachPenalty)) = nan; % Don't plot 2 deep penalty where we don't have 3 deep penalty. 
        
        plot([1:size(eachPenalty,1)]', eachPenalty2Deep, ...
            '-', 'linewidth', 0.75, 'Color', cmap(idatcomp,:)); 
        
        allEachPenalty2Deep(:,idatcomp) = eachPenalty2Deep; % Matrix to keep track of 2 deep penalty for each component
        if (~recalcOrder) && showMeanPens && (idatcomp == eachDatComp(end));
            allMean = mean(nanmean(allEachPenalty2Deep)) .* ones(size(eachPenalty2Deep)); 
            plot([1:size(eachPenalty,1)]', allMean, ...
                '--', 'linewidth', 0.75, 'Color', 'k', 'DisplayName', 'none');             
        end
    %     scatter(find(rmv3Lyr(penaltySortPlot)), [1 1].* eachPenalty2Deep(scndLyr),...
    %         40, cmap(idatcomp,:), 'filled' ); % find where the second layers label is. Make some scatter dots there. 
    end

    allBar = [allBar, eachPenalty];

    %%% Line plots
    if strcmp(lineOrBar, 'line'); 
        if iLayerDepth == 1; 
            scat1 = scatter([1:size(eachPenalty,1)]', eachPenalty, 40, cmap(idatcomp,:), '*', 'linewidth', 1); 
        elseif iLayerDepth ==3
            scat3 = scatter([1:size(eachPenalty,1)]', eachPenalty, 40, cmap(idatcomp,:), '*', 'linewidth', 1); 
            legPlots(idatcomp) = scat3; % Handle for making legend. 
        end
    end
    %%% 


    if strcmp(lineOrBar, 'line'); 
        if iLayerDepth == 3; 
            legPlotsExtend = [legPlots, plot([1 1], [0 0], '-k', 'DisplayName', '1-layer')]; 
            datCompLabelsExtend = datCompLabels; 
            datCompLabelsExtend{end+1} = ['Seismometer+depth']; 
            LGD = legend(legPlotsExtend, datCompLabelsExtend, 'location', 'best', 'numColumns', 2); 
    %         LGD.dynamicLegend = 'on'; 
    %         LGD = legend('-DynamicLegend'); 
    %         plot([1 1], [0 0], '-k', 'DisplayName', '3-layer'); 
    %         plot([1 1], [0 0], ':k', 'DisplayName', 'Seismometer + depth'); 
    %         plot([1 1], [0 0], '--k', 'DisplayName', '1-layer'); 
    %         set(get(LGD.AutoUpdate), 'off'); 
        end
    elseif strcmp(lineOrBar, 'bar'); 
        legend(bar1H, datCompLabels, 'location', 'southwest', 'numColumns', 2); 
    end
end % End each dat comp

% calculate the best order to plot penalties, from most reduction to least left to right. 
% if (iLayerDepth == 1) && all(penaltySortPlot == [1:length(penaltySortPlot)]'); % Don't calculate the new order if you were already re-ordering things!!!
%     meanPen = mean(allBar, 2); 
%     [~,penaltySortPlot] = sort(meanPen);
%     penaltySortPlot = penaltySortPlot(end:-1:1); 
%     save('penaltySortPlot.mat', 'penaltySortPlot'); 
% end % end sorting
if all(penaltySortPlot == [1:length(penaltySortPlot)]'); % Don't calculate the new order if you were already re-ordering things!!!
    meanPen = mean(allBar, 2);
    [~,penaltySortPlot] = sort(meanPen);
    penaltySortPlot = penaltySortPlot(end:-1:1); 
    save(['penaltySortPlotDepth' num2str(iLayerDepth) '.mat'], 'penaltySortPlot'); 
    save(['meanPenPlot' num2str(iLayerDepth) '.mat'], 'meanPen'); 
end % end sorting

%%% Bar plot
if strcmp(lineOrBar, 'bar'); 
if iLayerDepth == 3; 
    bar3H = bar(allBar, 'facecolor', [0, 0, 0])
elseif iLayerDepth == 1; 
    bar1H = bar(allBar); 
end
end
% End bar plot options

% Remaining plotting options
ylim([0 40 ]);  
set(gca, 'xticklabel', labelsAll(~isnan(eachPenalty)), 'XTickLabelRotation', 25,'XTick', find(~isnan(eachPenalty) )); % find(~isnan(eachpenalty)) gives positions ofticks to label. It excludes ones where we have a nan penalty.  

% x labels
% if iLayerDepth ~= eachLayerDepth(end); 
%     set(gca, 'xticklabel', []); 
% else 
    % set(gca, 'xticklabel', labelsAll(~isnan(eachPenalty)), 'XTickLabelRotation', 25,'XTick', find(~isnan(eachPenalty) )); % find(~isnan(eachpenalty)) gives positions ofticks to label. It excludes ones where we have a nan penalty.  
    % for itxt = [1:length(labelsAll)]; 
    %     textH = text(itxt, miny-1, [labelsAll{itxt} '   '] ,...
    %         'Rotation', 45, 'HorizontalAlignment', 'right'); 
    % end
    % set(gca, 'xtick', []); 
% end
% end x labels

if indLayerDepth == 1; 
    ylabel('Penalty reduction (%)'); 
end
box on; 
grid on; 
title(sprintf('%1.0f-Layer Hierarchy', iLayerDepth), 'fontweight', 'normal'); 
xlim([min(find(~isnan(eachPenalty))), max(find(~isnan(eachPenalty)))]); 

% label plots a and b for paper. 
plotLabels = {'(a)', '(b)'}; 
text(0.98, 0.96, plotLabels{indLayerDepth}, ...
    'fontsize', 12,...
    'units', 'normalized', ...
    'horizontalalignment', 'right', 'verticalalignment', 'top'); 

end % End main plotting loop

end

exportgraphics(gcf, 'FIGURES/clusteredPenaltiesCompilation.pdf')







