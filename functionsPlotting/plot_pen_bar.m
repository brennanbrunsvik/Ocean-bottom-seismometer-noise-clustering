% bb2021.08.12 Make some bar plot to consolidate all the final penalty
% information. 
%         

lineOrBar = 'line'; 
recalcOrder = false; % calculate the order of which variables did best at reducing penalty. 

whichAnalyze = [1, 5, 11]; 
% whichAnalyze = [1]; 

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

labelsAllUnsort = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 
rmv3Lyr = logical([1 0 0 0 0 0 0 1 0 0 0 ]'); 
frstLyr = 8; 
scndLyr = 1; 
        
datCompSpec = datCompSpec(whichAnalyze); 
symbolsScatter = symbolsScatter(whichAnalyze); 
datCompLabels = datCompLabels(whichAnalyze); 

% try; 
%     penaltySort = load('penaltySort.mat'); 
% catch; 
%     penaltySort = []; 
% end

% This chooses which analysis to do. Loop through all analyses, or just do
% some. 
eachLayerDepth = [3,1]; % plot 3 layer deep first, since penalties are lower, and bars goes beneath 1 layer deep
eachDatComp = [1:size(datCompSpec,2)]; 
eachQuant = [1:length(labelsAllUnsort)];  
        
figure(70); clf; set(gcf, 'pos', [-1269 494 1001 330]); hold on; 
% cmap = jet(length(eachDatComp));
% cmap = hsv(length(eachDatComp)); 
cmap = lines(length(eachDatComp)); 
% cmap = colorcube(length(eachDatComp)); 

legPlots = []; % Hold plot handles to add to legend. 
legPlotsLevel = []; % Hold plot handles to add to legend only showing dashed, dotted, etc. 
allBar = []; 
% title('sub-bars are fake for now')

for iLayerDepth = eachLayerDepth; % Do layer depths seperately. Easiest coding solution, since single or multiple layer analyses used the same figure windows, and were originally intended to run seperately. 
allBar = [];         
for idatcomp = eachDatComp; % Loop through all combinations of datswitcs, seismometer component, and spectra/coherance. 
% for idatcomp = [1:size(datcomp, 1)]; 
% iLayerDepth = 3; idatcomp = 1; disp('Delete this line')
thisDatCompSpec = datCompSpec{idatcomp}; 
datswitch   = thisDatCompSpec{1}; 
component   = thisDatCompSpec{2}; 
coh_or_spec = thisDatCompSpec{3}; 

% finPenFile = sprintf('pen_results/penalties_%s_datswitch%1.0f_component%1.0f_3layer.mat',... % TODO add in ilayerdepth
%     coh_or_spec, datswitch, component); % variable "eachPenalty"
finPenFile = sprintf('pen_results/penalties_%s_layerDepth%1.0f_datswitch%1.0f_component%1.0f.mat',...
    coh_or_spec, iLayerDepth, datswitch, component);
% eachPenalty = finalPenalty; % Delete this. 

finPenData = load(finPenFile).finPenData; 
penaltyUnClust = finPenData.penaltyUnClust; 
eachPenalty = finPenData.eachPenalty; 
eachPenalty = eachPenalty ./ penaltyUnClust .* 100; % normalize penalties to what it would be if they were not clustered
eachPenalty = 100 - eachPenalty; % Converting to penalty reduction

penaltySortPlot = [1:length(eachPenalty)]'; 
if ~ recalcOrder; 
    load('penaltySortPlot.mat'); 
end
eachPenalty = eachPenalty(penaltySortPlot); 
labelsAll = labelsAllUnsort(penaltySortPlot); 
% rmv3Lyr = rmv3Lyr(penaltySortPlot); 


pltLineWidth = 2; 

if iLayerDepth == 3; 
    % plot 2 deep penalty. 
    eachPenalty2Deep = finPenData.eachPenalty2Deep; 
    eachPenalty2Deep = 100-(eachPenalty2Deep ./ penaltyUnClust).*100; 
    eachPenalty2Deep = eachPenalty2Deep(penaltySortPlot); 
    plot([1:size(eachPenalty,1)]', eachPenalty2Deep, ...
        ':', 'linewidth', pltLineWidth.*.9, 'Color', cmap(idatcomp,:)); 
       
    scatter(find(rmv3Lyr(penaltySortPlot)), [1 1].* eachPenalty2Deep(scndLyr),...
        40, cmap(idatcomp,:), 'filled' ); % find where the second layers label is. Make some scatter dots there. 
    % remove data for the layers which were already accounted for. 
    eachPenalty(rmv3Lyr(penaltySortPlot)) = nan; % Have to keep the re-ordering rmv3Lyr here, or else it gets reordered 3 times. 
end




allBar = [allBar, eachPenalty];

%% Line plots
if strcmp(lineOrBar, 'line'); 
if iLayerDepth ==1; 
    linePlot1 = plot([1:size(eachPenalty,1)]', eachPenalty, ...
        '--', 'linewidth', pltLineWidth, 'Color', cmap(idatcomp,:)); 
else
    linePlot = plot([1:size(eachPenalty,1)]', eachPenalty, ...
        '-', 'linewidth', pltLineWidth, 'Color', cmap(idatcomp,:)); 
    legPlots(idatcomp) = linePlot; 
end
end
%%% end line plots


end

% if iLayerDepth == 1;
if (iLayerDepth == 1) && all(penaltySortPlot == [1:length(penaltySortPlot)]'); % Don't calculate the new order if you were already re-ordering things!!!
    meanPen = mean(allBar, 2); 
    [~,penaltySortPlot] = sort(meanPen);
    penaltySortPlot = penaltySortPlot(end:-1:1); 
    save('penaltySortPlot.mat', 'penaltySortPlot'); 
end


%%% Bar plot
if strcmp(lineOrBar, 'bar'); 
if iLayerDepth == 3; 
    bar3H = bar(allBar, 'facecolor', [0, 0, 0])
elseif iLayerDepth == 1; 
    bar1H = bar(allBar); 
end
end
%%%

end

% miny = min(min(allBar))-1; 
% maxy = max(max(allBar))+1; 
% ylim([miny, 100]); 
ylim([0 40 ]); 
% set(gca, 'YDir', 'reverse')


set(gca, 'xticklabel', labelsAll)
% for itxt = [1:length(labelsAll)]; 
%     textH = text(itxt, miny-1, [labelsAll{itxt} '   '] ,...
%         'Rotation', 45, 'HorizontalAlignment', 'right'); 
% end
% set(gca, 'xtick', []); 


ylabel('Penalty reduction (%)'); 
% xlabel('Penalty using this variable as third hierarchy depth'); 
% set(gca, 'ytick', []); 

box on; 
grid on; 

if strcmp(lineOrBar, 'line'); 
    legend(legPlots, datCompLabels, 'location', 'best', 'numColumns', 2)   
    legend('-DynamicLegend'); 
    plot([1 1], [0 0], '-k', 'DisplayName', '3-layer'); 
    plot([1 1], [0 0], ':k', 'DisplayName', 'Seismometer + depth'); 
    plot([1 1], [0 0], '--k', 'DisplayName', '1-layer'); 
elseif strcmp(lineOrBar, 'bar'); 
    legend(bar1H, datCompLabels, 'location', 'southwest', 'numColumns', 2); 
end
% legend('-DynamicLegend');
% scatter([0, 0], [0, 0])

exportgraphics(gcf, 'FIGURES/clusteredPenaltiesCompilation.pdf')







