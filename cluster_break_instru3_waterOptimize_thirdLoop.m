% clear; 
% close all; 
sameStasAllAnalyses = true; 
showSpectrograms = false; 
showPenalOptim = false; 
penaltyFunction = 'spectral_angle'; 
coh_or_spec = 'spec'; % coherance (coh) or spectra (spec)

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

for idatcomp = [1]; 
% for idatcomp = [1:size(datcomp, 1)]; 

thisDatCompSpec = datCompSpec{idatcomp}; 
datswitch   = thisDatCompSpec{1}; 
component   = thisDatCompSpec{2}; 
coh_or_spec = thisDatCompSpec{3}; 

eachPenalty = zeros(size(labelsAll,1), 1); % Penalty to collect while doing the iquant loop
% for iquant = [2]; 
for iquant = [1:length(labelsAll)]; % Slower to put the loop so high up in code, but makes it easier to think and develop the code. 

eachPenalty(iquant) = clusterWholeHierarchy(sameStasAllAnalyses, ...
    showSpectrograms, showPenalOptim, penaltyFunction, ...
    coh_or_spec, datswitch, component, iquant) % !!! Do all the real processing here. 
    
% eachPenalty(iquant) = penaltyTijk; 

end
end

finPenFile = sprintf('pen_results/penalties_%s_datswitch%1.0f_component%1.0f_3layer.mat',...
    coh_or_spec, datswitch, component); 
save(finPenFile, 'eachPenalty'); 


% Can plot histogram of final penalty, based on each third hierarchy depth
figure(70); clf; hold on; 
barh(eachPenalty)

set(gca, 'yticklabel', labelsAll)
for itxt = [1:length(labelsAll)]; 
    text(0, itxt, labelsAll{itxt}); 
end

xlabel('Penalty using this variable as third hierarchy depth'); 
set(gca, 'ytick', []); 

box on; 
grid on; 

exportgraphics(gcf, 'FIGURES/third_var_clusters_bar.pdf'); 



