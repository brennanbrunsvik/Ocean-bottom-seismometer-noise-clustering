% clear; 
% close all; 
sameStasAllAnalyses = true; 
showSpectrograms = true; 
showPenalOptim = false; 
penaltyFunction = 'spectral_angle'; 
coh_or_spec = 'spec'; % coherance (coh) or spectra (spec)
addpath('./boot'); 
addpath('./functionsPlotting'); 
addpath('./otherPplCode'); 

datCompSpec = {...
    {1,1,'spec'},... % 1
    {1,2,'spec'},... 
    {1,3,'spec'},...
    {1,4,'spec'},...
    {2,1,'spec'},...% 5
    {3,1,'spec'},...
    {1,1,'coh'},...
    {1,2,'coh'},...
    {1,3,'coh'},...
    {2,1,'coh'},... % Not positive if this is all of them. 
    {1,23,'spec'}... % 11. Both horizontal 1 and 2. 
    };

labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; % Should be able to remove this from here, but I was using it for size(...)

% This chooses which analysis to do. Loop through all analyses, or just do
% some. 
eachLayerDepth = [3]; % [1,3]; 
eachDatComp = [1]; % [1, 5, 11]; % [1:size(datCompSpec,2)]; 
eachQuant = [3]; [1:length(labelsAll)];         
savePenaltFile = false; 

% parpool(8); 
        
for iLayerDepth = eachLayerDepth; % Do layer depths seperately. Easiest coding solution, since single or multiple layer analyses used the same figure windows, and were originally intended to run seperately. 
for idatcomp = eachDatComp; % Loop through all combinations of datswitcs, seismometer component, and spectra/coherance. 
disp(sprintf('layer depth: %2.0f, datcomp: %2.0f', iLayerDepth, idatcomp))
thisDatCompSpec = datCompSpec{idatcomp}; 
datswitch   = thisDatCompSpec{1}; 
component   = thisDatCompSpec{2}; 
coh_or_spec = thisDatCompSpec{3}; 

eachPenalty      = zeros(size(labelsAll,1), 1); % Penalty to collect while doing the iquant loop
eachPenalty2Deep = nan  (size(labelsAll,1), 1); % Auxiliary info, but used for plotting later. only care if doing 3 layer hierarchy. 
eachPenalty1Deep = nan  (size(labelsAll,1), 1); 
penaltyUnClust   = nan  (size(labelsAll,1), 1); % only need this once, but this works in the parfor...
% for iquant = eachQuant; % If not doing plots, switch to parfor
for iquant = eachQuant; % Loop through each explanatory/independent variable ("quant" is here for legacy purpose basically) % Slower to put this loop so high up in code, but makes it easier to think and develop the code. 
% !!! Do all the real processing at this section.

    if iLayerDepth == 1; 
        [eachPenalty(iquant), penaltyUnClust(iquant)] ...
            = cluster1LayerHierarchy(sameStasAllAnalyses, ...
            showSpectrograms, showPenalOptim, penaltyFunction, ...
            coh_or_spec, datswitch, component, iquant);  % Single layer deep
    elseif iLayerDepth == 3; 
        [eachPenalty(iquant), eachPenalty2Deep(iquant), eachPenalty1Deep(iquant), penaltyUnClust(iquant)] ...
            = clusterWholeHierarchy(sameStasAllAnalyses, ...
            showSpectrograms, showPenalOptim, penaltyFunction, ...
            coh_or_spec, datswitch, component, iquant);   % Three layers deep
        % Not really a need to get penaltyUnClust each time. But this was easiest
        % to code. 
    end

end

finPenData = struct('eachPenalty', eachPenalty, ...
                    'eachPenalty2Deep', eachPenalty2Deep, ...
                    'eachPenalty3Deep', eachPenalty1Deep, ...
                    'labelsAll', labelsAll, ...
                    'penaltyUnClust', penaltyUnClust); % Add other things later. 
finPenFile = sprintf('pen_results/penalties_%s_layerDepth%1.0f_datswitch%1.0f_component%1.0f.mat',...
    coh_or_spec, iLayerDepth, datswitch, component); 
if savePenaltFile; 
    save(finPenFile, 'finPenData');
end
% disp('NOT SAVING FINPENFILE RIGHT NOW')

% % Can plot histogram of final penalty, based on each third hierarchy depth
% figure(70); clf; hold on; 
% barh(eachPenalty)
% 
% set(gca, 'yticklabel', labelsAll)
% for itxt = [1:length(labelsAll)]; 
%     text(0, itxt, labelsAll{itxt}); 
% end
% 
% xlabel('Penalty using this variable as SOME hierarchy depth (First or third? TODO)'); 
% set(gca, 'ytick', []); 
% 
% box on; 
% grid on; 
% 
% exportgraphics(gcf, 'FIGURES/bar_single_analysis.pdf'); 

end
end



