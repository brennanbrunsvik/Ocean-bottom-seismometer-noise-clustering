function [penaltyT, penaltyUnClust] = cluster1LayerHierarchy(sameStasAllAnalyses, ...
    showSpectrograms, showPenalOptim, penaltyFunction, ...
    coh_or_spec, datswitch, component, iquant); 

componentFull = component; 

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

penWholeData = cluster_spread(dat, fnew, 'Whole cluster', nan, ...
    showPlot=false, penalty=penaltyFunction); 
sprintf('Penalty for all data, before subdivisions: %1.3f', penWholeData)
% penTempTrue = cluster_spread(dat(thisboolTemp,:),...
%         fnew, 'Temporary', nan, ...
%         showPlot=false, penalty=penaltyFunction)


if ~isCat(iquant); % If is quantitative variable
    figSaveName = sprintf('%s_Datswitch%1.0f_Comp%2.0f___penalty_optimization_first_layer.pdf', coh_or_spec, datswitch, componentFull);  
    if strcmp(figSaveName, 'spec_Datswitch1_Comp 1___penalty_optimization_first_layer.pdf'); 
        figSaveName = 'penalty_optimization_water_depth_Z.pdf'; 
    elseif strcmp(figSaveName, 'spec_Datswitch1_Comp23___penalty_optimization_first_layer.pdf'); 
        figSaveName = 'penalty_optimization_water_depth_H.pdf'; 
    elseif strcmp(figSaveName, 'spec_Datswitch2_Comp 1___penalty_optimization_first_layer.pdf'); 
        figSaveName = 'penalty_optimization_water_depth_Zcorr.pdf'; 
    end
    
    thisax = subplot(4, 4, thissubplot); thissubplot = thissubplot + 1; 
    plot146Struct = nan; 
    showPlot146 = false; 
    if iquant == 1; 
        showPlot146 = true;        
        plot146Struct = struct(...
            'figSaveName', ['FIGURES/penalty_optimization/grid_search_' figSaveName]); 
        plot146Struct.figDatName = sprintf('FIGURES/penalty_optimization/grid_search_comp_%2.0f_datType_%1.0f_data.mat', componentFull, datswitch); 
    end
    
    [     eachPenaltyTempTrue,...
      eachPenaltyTempFalse,...
      eachPenaltyTempTot, ...
      eachPenaltyTempTrueN,...
      eachPenaltyTempFalseN,...
      eachPenaltyTempTotN,...
      penBreak...
      ] = optimize_penalty(OthVarMat(iquant, :), dat, fnew, penaltyFunction, ...
          thisax, showPenalOptim(1), 100, 'showPlot146', showPlot146, ...
          'plot146Struct', plot146Struct ); 
    title(sprintf('%s: min pen = %2.1f', labelsAll{iquant}, min(eachPenaltyTempTotN) ) ); 
%     penaltyT = min(eachPenaltyTempTotN);
    penaltyT = min(eachPenaltyTempTot); 
    
    
   
    % bb2021.09.30 Plot the geq and leq data groups
    figure(208); clf; hold on; 
    set(gcf, 'pos', [440 454 1166 344]); 
    [penMin, penMinI] = min(eachPenaltyTempTot); 
    breakPen = penBreak(penMinI); 
    dat1Boo = OthVarMat(iquant, :) >=breakPen; % In calusterWholeHierarchy I use >= and < I think
    dat2Boo = OthVarMat(iquant, :) < breakPen; 
    indVar1 = OthVarMat(iquant, dat1Boo); % Independent variable 1, the large values. 
    indVar2 = OthVarMat(iquant, dat2Boo); % Independent variable 2, the small values. 
    pen1 = cluster_spread(dat(dat1Boo,:), fnew, 'x \geq', subplot(1,3,2), 'showPlot', 'true', ...
        'penalty', penaltyFunction, 'barePlot', 'false', 'addColorbar', true);
    xlabel(sprintf('\\geq %1.0f',min(indVar1))); 
    pen1av = pen1/sum(dat1Boo); 
    title(sprintf('Pav=%1.2f', pen1av)); 
    pen2 = cluster_spread(dat(dat2Boo,:), fnew, 'x <', subplot(1,3,3), 'showPlot', 'true', ...
        'penalty', penaltyFunction, 'barePlot', 'false', 'addColorbar', true); 
    xlabel(sprintf('\\leq %1.0f',max(indVar2))); 
    pen2av = pen2/sum(dat2Boo);     
    title(sprintf('Pav=%1.2f', pen2av)); 
    penA = cluster_spread(dat           , fnew, 'all', subplot(1,3,1)           , 'showPlot', 'true', ...
        'penalty', penaltyFunction, 'barePlot', 'false', 'addColorbar', true); 
    xlabel('All data'); 
    title(sprintf('Pav=%1.2f', penA/size(dat,1) )); 
    sprintf([newline newline newline...
        'For optimized dataset (water?) on %s, optimal split value (depth?) = %1.0f'...
        newline newline newline], ...
        '???', breakPen)
    thisDat = OthVarMat(iquant,:); 
    sprintf('For LARGE (deep?) subset: smallest value is: %1.0f', min(thisDat(dat1Boo)))
    sprintf('For SMALL (shallow?) subset: largest value is: %1.0f', max(thisDat(dat2Boo)))
       
    exportgraphics(gcf, ['FIGURES/penalty_optimization/' figSaveName], ...
        'ContentType', 'Vector');
    
    
  
    
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
