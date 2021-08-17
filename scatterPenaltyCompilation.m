% bb2021.08.12 Make some bar plot to consolidate all the final penalty
% information. 
%         
%         
% coh_or_spec = 'spec'; 
% datswitch = 1; 
% component = 1; 

lineOrBar = 'scatter'; 

whichAnalyze = [1, 5, 11]; 

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

labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 
        
datCompSpec = datCompSpec(whichAnalyze); 
symbolsScatter = symbolsScatter(whichAnalyze); 
datCompLabels = datCompLabels(whichAnalyze); 

% This chooses which analysis to do. Loop through all analyses, or just do
% some. 
eachLayerDepth = [1,3]; % plot 3 layer deep first, since penalties are lower, and bars goes beneath 1 layer deep
eachDatComp = [1:size(datCompSpec,2)]; 
eachQuant = [1:length(labelsAll)];  
        
figure(70); clf; set(gcf, 'pos', [-1269 495 567 477]); hold on; 
% cmap = jet(length(eachDatComp));
% cmap = hsv(length(eachDatComp)); 
% cmap = lines(length(eachDatComp)); 
cmap = colorcube(length(eachDatComp)); 

legPlots = []; % Hold plot handles to add to legend. 
allBar = []; 
% title('sub-bars are fake for now')

% for iLayerDepth = eachLayerDepth; % Do layer depths seperately. Easiest coding solution, since single or multiple layer analyses used the same figure windows, and were originally intended to run seperately. 
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
    coh_or_spec, 1, datswitch, component);
% eachPenalty = finalPenalty; % Delete this. 

finPenData = load(finPenFile).finPenData; 
penaltyUnClust = finPenData.penaltyUnClust; 
eachPenalty1 = finPenData.eachPenalty; 
eachPenalty1 = eachPenalty1 ./ penaltyUnClust .* 100; % normalize penalties to what it would be if they were not clustered
eachPenalty1 = 100 - eachPenalty1; % Converting to penalty reduction



finPenFile = sprintf('pen_results/penalties_%s_layerDepth%1.0f_datswitch%1.0f_component%1.0f.mat',...
    coh_or_spec, 3, datswitch, component);
% eachPenalty = finalPenalty; % Delete this. 

finPenData = load(finPenFile).finPenData; 
penaltyUnClust = finPenData.penaltyUnClust; 
eachPenalty3 = finPenData.eachPenalty; 
eachPenalty3 = eachPenalty3 ./ penaltyUnClust .* 100; % normalize penalties to what it would be if they were not clustered
eachPenalty3 = 100 - eachPenalty3; % Converting to penalty reduction


scatterDatComp = scatter(eachPenalty1, eachPenalty3, ...
    90, [1:length(eachPenalty3)], symbolsScatter{idatcomp}, 'linewidth', 10 ); 



pltLineWidth = 2; 


% allBar = [allBar, eachPenalty];

% Line plots
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
%% end line plots
% scatter(eachPenalty)

end

% forLeg = scatter( zeros(length(eachPenalty3), 1), zeros(length(eachPenalty3),1), ...
%     90, [1:length(eachPenalty3)], '.', 'filled'); 

%%% Bar plot
if strcmp(lineOrBar, 'bar'); 
if iLayerDepth == 3; 
    bar(allBar, 'facecolor', [0, 0, 0])
elseif iLayerDepth == 1; 
    bar(allBar); 
end
end
%%

% end

% miny = min(min(allBar))-1; 
% maxy = max(max(allBar))+1; 
% ylim([miny, 100]); 
ylim([0 40 ]); 
xlim([0 25 ]); 
% set(gca, 'YDir','reverse')


% set(gca, 'xticklabel', labelsAll)
% for itxt = [1:length(labelsAll)]; 
%     textH = text(itxt, miny-1, [labelsAll{itxt} '   '] ,...
%         'Rotation', 45, 'HorizontalAlignment', 'right'); 
% end
% set(gca, 'xtick', []); 


ylabel('3 layer: penalty reduction (%)'); 
xlabel('1 layer: penalty reduction (%)'); 

plot([0 100], [0 100], '-k')
% xlabel('Penalty using this variable as third hierarchy depth'); 
% set(gca, 'ytick', []); 

legPlots = []; 
for ivar = [1:length(eachPenalty3)]; 
    legPlots(end+1) = scatter([-999, -999], [-999, -999], 90, [ivar, ivar], 'o', 'filled'); 
end
for ivar = [1:length(eachDatComp)]; 
    legPlots(end+1) = scatter([-999, -999], [-999, -999], 90, 'k', symbolsScatter{ivar}); 
end
legend(legPlots, {labelsAll{:}, datCompLabels{:}}, 'location', 'best', 'numColumns' , 2); 

box on; 
grid on; 

if strcmp(lineOrBar, 'line'); 
    legend(legPlots, datCompLabels, 'location', 'best', 'numColumns', 2)
elseif strcmp(lineOrBar, 'bar'); 
    legend(legPlots, datCompLabels, 'location', 'southwest', 'numColumns', 2); 
end

exportgraphics(gcf, 'FIGURES/clusteredPenaltiesCompilationScatter.png')
