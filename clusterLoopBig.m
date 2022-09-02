clear; 
close all; 

sameStasAllAnalyses = true; % Don't use a station unless it can be used in every analysis. 
showSpectrograms = false; % Set to false to save some time. 
penaltyFunction = 'spectral_angle'; % Spectral angle or Euclidean (check code for precise spelling). 
coh_or_spec = 'spec'; % coherance (coh) or spectra (spec)

addpath('./boot'); 
addpath('./functionsPlotting'); 
addpath('./otherPplCode'); 
set(groot, 'defaultAxesFontName', 'helvetica'); 

% Which combination of data, station component, and whether using spectra or coherance. Choose a combination using an integer. I think 1, 5, and 11 are most important. 
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

% Should be able to remove this from here, but I was using it for size(...)
labelsAll = {'Water Depth','Distance to Plate Boundary','Distance from Land',...
    'Crustal Age','Sediment Thickness','Surface Current','Instrument Design',...
	'Seismometer','Pressure Gauge','Environment','Experiment Name'}; % Applies to each quant
save('labelsAll', 'labelsAll'); % For loading in some functions, I think. 
        
        
% This chooses which analysis to do. Loop through all analyses, or just do some. 
eachLayerDepth = [3]; % [1,3]; % Refers to the number of layers/hierarchies
% eachDatComp = [1:size(datCompSpec,2)]; 
eachDatComp = [1]; % [1, 5, 11]; % Refers to datCompSpec
eachQuant = [3]; % [1:length(labelsAll)]; % Refers to which quality to assess. Pick any from LabelsAll.   
% eachQuant = 1; 
savePenaltFile = false; if savePenaltFile; warning('You are overwriting penalty files that are used for plotting!'); end % Save penalty calculation files. At some point you have to do this, and loop through all hierarchy depths and labels, so that we can make plots of all those results. 


        
for iLayerDepth = eachLayerDepth; % Do layer depths seperately. Easiest coding solution, since single or multiple layer analyses used the same figure windows, and were originally intended to run seperately. 
for idatcomp = eachDatComp; % Loop through all combinations of datswitcs, seismometer component, and spectra/coherance. 
    
fprintf('Running layer depth: %2.0f, datcomp: %2.0f\n', iLayerDepth, idatcomp)

thisDatCompSpec = datCompSpec{idatcomp}; 
datswitch   = thisDatCompSpec{1}; 
component   = thisDatCompSpec{2}; 
coh_or_spec = thisDatCompSpec{3}; 

% finPenFile = sprintf('pen_results/penalties_%s_layerDepth%1.0f_datswitch%1.0f_component%1.0f.mat',...
%     coh_or_spec, iLayerDepth, datswitch, component) % I think store penalty information in this file, for the specific datcomp/layerdepth. 

eachPenalty      = zeros(size(labelsAll,1), 1); % Penalty to collect while doing the iquant loop
eachPenalty2Deep = nan  (size(labelsAll,1), 1); % Auxiliary info, but used for plotting later. Only care if doing 3 layer hierarchy. 
eachPenalty1Deep = nan  (size(labelsAll,1), 1); 
penaltyUnClust   = nan  (size(labelsAll,1), 1); % Penalty of data before clustering any of it. only need this once, but this works in the parfor... 

% parfor iquant = eachQuant; % If not doing plots, switch to parfor
for iquant = eachQuant; % Loop through each explanatory/independent variable ("quant" is here for legacy purpose basically) % Slower to put this loop so high up in code, but makes it easier to think and develop the code. 

    
    %%% Wrap code for all the processing. 
    if iLayerDepth == 1; % If doing only one layer. 
        showPenalOptim = logical(1); 
        
        [eachPenalty(iquant), penaltyUnClust(iquant)] ...
            = cluster1LayerHierarchy(sameStasAllAnalyses, ...
            showSpectrograms, showPenalOptim, penaltyFunction, ...
            coh_or_spec, datswitch, component, iquant); 
    elseif iLayerDepth == 3; % If doing three layers. 
        showPenalOptim = logical([0 0 0]); % Which layers to plot penalties of
        
        [eachPenalty(iquant), eachPenalty2Deep(iquant), eachPenalty1Deep(iquant), penaltyUnClust(iquant)] ...
            = clusterWholeHierarchy(sameStasAllAnalyses, ...
            showSpectrograms, showPenalOptim, penaltyFunction, ...
            coh_or_spec, datswitch, component, iquant);   
    end
    %%% END Wrap code for all the processing. 

end

finPenData = struct('eachPenalty', eachPenalty', ...
                    'eachPenalty2Deep', eachPenalty2Deep', ...
                    'eachPenalty3Deep', eachPenalty1Deep', ...
                    'labelsAll', labelsAll', ...
                    'penaltyUnClust', penaltyUnClust'); % Add other things later. 
                
finPenFile = sprintf('pen_results/penalties_%s_layerDepth%1.0f_datswitch%1.0f_component%1.0f.mat',...
    coh_or_spec, iLayerDepth, datswitch, component); 

if savePenaltFile; 
    save(finPenFile, 'finPenData');
end


end
end



