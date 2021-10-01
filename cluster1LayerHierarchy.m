function [penaltyT, penaltyUnClust] = cluster1LayerHierarchy(sameStasAllAnalyses, ...
    showSpectrograms, showPenalOptim, penaltyFunction, ...
    coh_or_spec, datswitch, component, iquant); 



OBS_TableParams;
prep_data_wrapper; 
% if strcmp(coh_or_spec, 'coh'); 
%     prep_data_coh; 
% else
%     prep_data; 
% end

% % OthVarMat has data of this style: 
% % numeric, continuous, no nan. 
% OthVarMat
% suff{1} = 'Water Depth (m)';
% suff{2} = 'Plate Bndy Dist (km)';
% suff{3} = 'Coastline Dist (km)';
% suff{4} = 'Crustal Age (Myr)';
% suff{5} = 'Sediment Thickness (m)';
% suff{6} = 'Surface Current (m/s)';
% % Cats has the categorical stuff
% categorical
% suff{7} = 'OBS Design';
% suff{8} = 'Seismometer'; Any of "ç"    "Trillium 240"    "Trillium Compact"
% suff{9} = 'Pressure Gauge';
% suff{10} = 'Environment'; Any of "Gulf of Alaska"    "Gulf of California"    "Lake Malawi"    "North Atlantic"    "North Pacific"    "Solomon Sea"    "South Pacific"    "Tasman Sea"
% suff{11} = 'Experiment';

% waterDepthCut = 1000; 

mergedData = {OthVarMat(1,:), OthVarMat(2,:), OthVarMat(3,:),...
    OthVarMat(4,:), OthVarMat(5,:), OthVarMat(6,:)...
    string(cats(7).data), string(cats(8).data), string(cats(9).data),...
    string(cats(10).data), string(cats(11).data)}; 
isCat = logical([0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1]); 

% labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
%             'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
%             'OBS Design'; 'Seismometer'; 'Pressure Gauge'; 'Environment'; 'Experiment'}; 
load('labelsAll'); 
        
if showSpectrograms || showPenalOptim(1);        
    figure(132); clf; hold on; set(gcf, 'pos', [2017 342 2767 1656]); % Figure to hold a bunch of spectra and other things
else
    thisax = nan; 
end
pltn = 5; pltm = 7; % rows by collumns of main plot
thissubplot = 1;

% thisax = subplot(pltm, pltn, thissubplot); 


if ~isCat(iquant); % If is quantitative variable
    thisax = subplot(4, 4, thissubplot); thissubplot = thissubplot + 1; 
    [     eachPenaltyTempTrue,...
      eachPenaltyTempFalse,...
      eachPenaltyTempTot, ...
      eachPenaltyTempTrueN,...
      eachPenaltyTempFalseN,...
      eachPenaltyTempTotN,...
      penBreak...
      ] = optimize_penalty(OthVarMat(iquant, :), dat, fnew, penaltyFunction, ...
          thisax, showPenalOptim(1), 100); 
    title(sprintf('%s: min pen = %2.1f', labelsAll{iquant}, min(eachPenaltyTempTotN) ) ); 
%     penaltyT = min(eachPenaltyTempTotN);
    penaltyT = min(eachPenaltyTempTot); 
    
    % bb2021.09.30 Plot the geq and leq data groups
    figure(208); clf; hold on; 
    [penMin, penMinI] = min(eachPenaltyTempTot); 
    breakPen = penBreak(penMinI); 
    dat1Boo = OthVarMat(iquant, :) >=breakPen; % In calusterWholeHierarchy I use >= and < I think
    dat2Boo = OthVarMat(iquant, :) < breakPen; 
    cluster_spread(dat(dat1Boo,:), fnew, 'x \geq', subplot(1,2,1), 'showPlot', 'true', ...
        'penalty', penaltyFunction, 'barePlot', 'false', 'addColorbar', true);
    cluster_spread(dat(dat2Boo,:), fnew, 'x <', subplot(1,2,2), 'showPlot', 'true', ...
        'penalty', penaltyFunction, 'barePlot', 'false', 'addColorbar', true); 
    
    sprintf([newline newline newline...
        'For optimized dataset (water?) on %s, optimal split value (depth?) = %1.0f'...
        newline newline newline], ...
        '???', breakPen)
    
    % TODO need to get spectra plots going here
else % If is a categorical data
%     figure(232); clf; hold on; set(gcf, 'pos', [2017 342 2767 1656]); 
    [c1, ia1, ic1] = unique(cats(iquant).data ); 
    eachPen = nan(size(c1, 2),1); 
    for idat = [1:max(ic1)]; % Loop through each unique categorical thing
        thisax = subplot(pltn, pltm, idat); thissubplot = thissubplot + 1;
        thisBool = idat == ic1; 
        thisCluster = dat(thisBool, :); 
        penalty = cluster_spread(thisCluster, fnew, ... % replace(thisname, '\newline', '|'), thisax, ...
            ' ', thisax, showPlot=showSpectrograms, penalty=penaltyFunction);
        eachPen(idat) = penalty; 
    end
    totPen = nansum(eachPen); % In some cases there might be only one instance of some variable. The cluster has nan spread. Just don't even count that... 
%     penNorm = totPen / size(ic1, 1); % / sum(~isnan(eachPen)); % Divide by number of clusters that having something in them
    penaltyT = totPen;
end

penaltyUnClust = cluster_spread(dat, fnew, 'All data', gca, showPlot=false, penalty=penaltyFunction);

end
