% clear; 
% close all; 

showSpectrograms = true; 
showPenalOptim = true; 
penaltyFunction = 'spectral_angle'; 
coh_or_spec = 'spec'; % coherance (coh) or spectra (spec)

OBS_TableParams;
datswitch = 1; % Look in prep data
component = 1; % Look in prep data

prep_data; % Get spectra

% % % % OthVarMat has data of this style: 
% % % % numeric, continuous, no nan. 
% % % OthVarMat
% % % suff{1} = 'Water Depth (m)';
% % % suff{2} = 'Plate Bndy Dist (km)';
% % % suff{3} = 'Coastline Dist (km)';
% % % suff{4} = 'Crustal Age (Myr)';
% % % suff{5} = 'Sediment Thickness (m)';
% % % suff{6} = 'Surface Current (m/s)';
% % % % Cats has the categorical stuff
% % % categorical
% % % suff{7} = 'OBS Design';
% % % suff{8} = 'Seismometer'; Any of "ç"    "Trillium 240"    "Trillium Compact"
% % % suff{9} = 'Pressure Gauge';
% % % suff{10} = 'Environment'; Any of "Gulf of Alaska"    "Gulf of California"    "Lake Malawi"    "North Atlantic"    "North Pacific"    "Solomon Sea"    "South Pacific"    "Tasman Sea"
% % % suff{11} = 'Experiment';
% % 
% % % waterDepthCut = 1000; 

labelsNums = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current'};
figure(1); clf; set(gcf, 'pos', [2212 826 1320 1129]); thissubplot = 1; 
numPens = nan(size(OthVarMat, 1), 1); 
for iquant = [1:size(OthVarMat, 1)]; % Loop through each quantitative explanatory variable
    thisax = subplot(4, 4, thissubplot); 
    thissubplot = thissubplot + 1; 
    [     eachPenaltyTempTrue,...
      eachPenaltyTempFalse,...
      eachPenaltyTempTot, ...
      eachPenaltyTempTrueN,...
      eachPenaltyTempFalseN,...
      eachPenaltyTempTotN,...
      penBreak...
      ] = optimize_penalty(OthVarMat(iquant, :), dat, fnew, penaltyFunction, ...
          thisax, showPenalOptim, 100); 
    title(sprintf('%s: min pen = %2.1f', labelsNums{iquant}, min(eachPenaltyTempTotN) ) ); 
    numPens(iquant) = min(eachPenaltyTempTotN); 
end

labelsCats = {'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}
catPens = nan(size(cats, 2), 1); 
for icat = [size(OthVarMat, 1) + 1: size(cats, 2)]; 
    [c1, ia1, ic1] = unique(cats(icat).data ); 
    eachPen = nan(size(c1, 2),1); 
    for idat = [1:max(ic1)]; % Loop through each unique categorical thing
        thisBool = idat == ic1; 
        thisCluster = dat(thisBool, :); 
        penalty = cluster_spread(thisCluster, fnew, ... % replace(thisname, '\newline', '|'), thisax, ...
            ' ', nan, showPlot=false, penalty=penaltyFunction);
        eachPen(idat) = penalty; 
    end
    totPen = nansum(eachPen); % In some cases there might be only one instance of some variable. The cluster has nan spread. Just don't even count that... 
    penNorm = totPen / size(ic1, 1); % / sum(~isnan(eachPen)); % Divide by number of clusters that having something in them
    catPens(icat) = penNorm;
end
catPens = catPens(size(OthVarMat, 1)+1:end); 



%% Plot all 
allPens = [numPens; catPens]; 
labelsAll = {''; 'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment';''}; 
% labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
%             'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
%             'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 
figure(7); clf; hold on; 
barh(allPens)
% set(gca, 'yticklabel', labelsAll)
for itxt = [0:length(labelsAll)-1]; 
    text(0, itxt, labelsAll{itxt+1}); 
end

xlabel('Penalty after separating by just this variable'); 
set(gca, 'ytick', []); 

box on; 
grid on; 

exportgraphics(gcf, 'FIGURES/single_var_clusters_bar.pdf'); 