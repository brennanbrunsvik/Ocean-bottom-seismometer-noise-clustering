% bb2021.08.12 Make some bar plot to consolidate all the final penalty
% information. 
%         
%         
% coh_or_spec = 'spec'; 
% datswitch = 1; 
% component = 1; 
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
    };

datCompLabels = {'Spec Z', 'Spec H1', 'Spec H2', 'Spec P', ... % Uncorrected spec
    'Spec Z, tilt+compliance', 'Spec Z, tilt',... % Corrected spec
    'Z-H1', 'Z-H2', 'Z-P', 'Z-P, tilt+compliance'}; % Coherance

labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 

% This chooses which analysis to do. Loop through all analyses, or just do
% some. 
eachLayerDepth = [1,3]; % plot 3 layer deep first, since penalties are lower, and bars goes beneath 1 layer deep
eachDatComp = [1:size(datCompSpec,2)]; 
eachQuant = [1:length(labelsAll)];  
        
figure(70); clf; set(gcf, 'pos', [-1269 494 1001 330]); hold on; 
% cmap = jet(length(eachDatComp));
cmap = hsv(length(eachDatComp)); 
legPlots = []; % Hold plot handles to add to legend. 
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


pltLineWidth = 2; 


allBar = [allBar, eachPenalty];

%% Line plots
if iLayerDepth ==1; 
    linePlot1 = plot([1:size(eachPenalty,1)]', eachPenalty, ...
        '--', 'linewidth', pltLineWidth, 'Color', cmap(idatcomp,:)); 
else
    linePlot = plot([1:size(eachPenalty,1)]', eachPenalty, ...
        '-', 'linewidth', pltLineWidth, 'Color', cmap(idatcomp,:)); 
    legPlots(idatcomp) = linePlot; 
end
%%% end line plots


end

%%% Bar plot
% if iLayerDepth == 3; 
%     bar(allBar, 'facecolor', [0, 0, 0])
% elseif iLayerDepth == 1; 
%     bar(allBar); 
% end
%%%

end

% miny = min(min(allBar))-1; 
% maxy = max(max(allBar))+1; 
% ylim([miny, 100]); 
ylim([40 100]); 

set(gca, 'xticklabel', labelsAll)
% for itxt = [1:length(labelsAll)]; 
%     textH = text(itxt, miny-1, [labelsAll{itxt} '   '] ,...
%         'Rotation', 45, 'HorizontalAlignment', 'right'); 
% end
% set(gca, 'xtick', []); 


ylabel('clustered penalty / unclustered penalty (%)'); 
% xlabel('Penalty using this variable as third hierarchy depth'); 
% set(gca, 'ytick', []); 

box on; 
grid on; 

legend(legPlots, datCompLabels, 'location', 'best', 'numColumns', 2)

exportgraphics(gcf, 'FIGURES/clusteredPenaltiesCompilation.pdf')
