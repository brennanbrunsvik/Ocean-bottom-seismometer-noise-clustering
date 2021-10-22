function [thissubplot, thisname, thisbool, penBreakBest, datMax, datMin] = clusterAtHierarchy(loopOptimizePenalty, ijk, index, nextIndex, ...
    thissubplot, pltn, pltm, dataSet, ...
    dat, fnew, penaltyFunction, showPenalOptim, bools, names, options); 
    arguments
            loopOptimizePenalty
            ijk
            index
            nextIndex
            thissubplot
            pltn
            pltm
            dataSet
            dat
            fnew
            penaltyFunction
            showPenalOptim
            bools
            names
            options.thisname = nan
            options.thisbool = nan
            options.optimPlotStruct = nan
    end
%

depthHier = find(string({'i', 'j', 'k'})==ijk); 

if strcmp(ijk, 'i'); 
    thisname = names{depthHier}{index}; 
	thisbool = logical(ones(size(dat,1), 1)); 
else
    thisname = [options.thisname '\newline' names{depthHier}{index}]; 
    thisbool = options.thisbool; 
end

if loopOptimizePenalty(depthHier); 
    if showPenalOptim & (index==1) & (nextIndex==0);
        showthisplot = true; 
        figure(132); 
%         thisax = subplot(pltn, pltm, thissubplot); 
%         thissubplot = thissubplot + 1; % On Figure 132  
        thisax = subplot(3,1,depthHier); 
    else
        showthisplot = false; 
        thisax = nan; 
    end
    

    
%     if strcmp('string', class(dataSet)); % This is categorical. Just break into categories? 
%     end
    
    [     eachPenaltyTempTrue,...
          eachPenaltyTempFalse,...
          eachPenaltyTempTot, ...
          eachPenaltyTempTrueN,...
          eachPenaltyTempFalseN,...
          eachPenaltyTempTotN,...
          penBreak...
          ] = optimize_penalty(dataSet(thisbool), dat(thisbool,:), fnew, penaltyFunction, ...
              thisax, showthisplot, 100, 'showPlot145', showthisplot,...
              'optimPlotStruct', options.optimPlotStruct); 
      [minPen, ipenBreak] = min(eachPenaltyTempTot); 
      penBreakBest = penBreak(ipenBreak); 
      cutInd = penBreakBest; 
      
    if index == 1; 
      thisboolNew = (dataSet  < penBreakBest)'; % 
    elseif index == 2; 
      thisboolNew = (dataSet >= penBreakBest)'; % excludes nans!!!! any nans will come back as false. They are evaluated when index == 3. 
    elseif index == 3; 
      thisboolNew = isnan(dataSet)'; 
    end
      
    datMax = max(dataSet(and(thisboolNew, thisbool))); % highest value data within this new subgroup. 
    datMin = min(dataSet(and(thisboolNew, thisbool))); % lowest value data within this new subgroup. 

else; 
    thisboolNew = bools{depthHier}{index}; % Base level boolean. The dataset corresponding to thisname. 
    penBreakBest = NaN; 
    datMax = nan; 
    datMin = nan; 
end

% thisname = sprintf('%s \n %s - %4.0f m \n', thisname, names{2}{j}, cut2)
% % TODO need to put this back, with cut2
thisbool = and(thisboolNew, thisbool); 

% if strcmp('i', ijk); 
% thisname = names{depthHier}{index}; % Base level name. e.g. "shallow" or "deep"
% else


end