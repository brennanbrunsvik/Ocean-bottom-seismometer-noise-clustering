function [eachPenaltyTempTrue,...
          eachPenaltyTempFalse,...
          eachPenaltyTempTot, ...
          eachPenaltyTempTrueN,...
          eachPenaltyTempFalseN,...
          eachPenaltyTempTotN,...
          newBreaks...
          ] = optimize_penalty(thisData, dat, fnew, penaltyFunction, thisax, showPlot, numCut, options); 
arguments
    thisData
    dat
    fnew
    penaltyFunction
    thisax
    showPlot
    numCut
    options.showPlot145 = false; 
    options.optimPlotStruct = nan; 
end
    
% thisData = dataSets.data1; 

newBreaks = sort(unique(thisData)); % Try values corresponding to each station. % linspace(min(thisData), max(thisData), numCut); 
eachPenaltyTempTrue = nan(size(newBreaks)); 
eachPenaltyTempFalse = nan(size(newBreaks)); 
eachPenaltyTempTot = nan(size(newBreaks)); 
eachPenaltyTempTrueN = nan(size(newBreaks)); 
eachPenaltyTempFalseN = nan(size(newBreaks)); 
eachPenaltyTempTotN = nan(size(newBreaks)); 

numFalse = nan(size(newBreaks)); 
numTrue  = nan(size(newBreaks)); 

for ibreak = [1:length(newBreaks)]; 
    thisboolTemp = thisData < newBreaks(ibreak); 
    numTrue(ibreak ) = sum( thisboolTemp);
    numFalse(ibreak) = sum(~thisboolTemp); 
    penTempTrue = cluster_spread(dat(thisboolTemp,:),...
        fnew, 'Temporary', nan, ...
        showPlot=false, penalty=penaltyFunction);
    penTempFalse = cluster_spread(dat(~thisboolTemp,:),...
        fnew, 'Temporary', nan, ...
        showPlot=false, penalty=penaltyFunction) ;
    penTempTot = penTempTrue + penTempFalse; 

    eachPenaltyTempTrue (ibreak) = penTempTrue; 
    eachPenaltyTempFalse(ibreak) = penTempFalse; 
    eachPenaltyTempTot  (ibreak) = penTempTot; 
    eachPenaltyTempTrueN(ibreak) = penTempTrue / sum(thisboolTemp); 
    eachPenaltyTempFalseN(ibreak) = penTempFalse / sum(~thisboolTemp);
    eachPenaltyTempTotN(ibreak) = ...
        (eachPenaltyTempTrue (ibreak) + eachPenaltyTempFalse(ibreak) ) ...
        / numel(thisboolTemp); 
end

if showPlot; 
    % Commented code here which shows non-normalized penalties. 
% % figure(16); clf; hold on; set(gcf, 'pos', [2495 1062 461 318]); 
% falsePlt = plot(newBreaks, eachPenaltyTempFalse, 'b'); 
% truePlt  = plot(newBreaks, eachPenaltyTempTrue , 'r'); 
% sumPlt   = plot(newBreaks, eachPenaltyTempTot  , 'k'); 
% legend([falsePlt, truePlt, sumPlt], {'Greater than', 'Less than', 'Total Penalty'}); 
% xlabel('Independent variable cutoff'); 
% ylabel('Penalty'); 
% % exportgraphics(gcf, 'Figures/manual_sep/cutoff.pdf'); 

% figure(17); clf; hold on; set(gcf, 'pos', [2395 1062 461 318]); 
axes(thisax); hold on; 
box on; 
title('Penalty f(cluster cut-off)')
falsePlt = plot(newBreaks, eachPenaltyTempFalseN, 'b', 'linewidth', 1.5); 
truePlt  = plot(newBreaks, eachPenaltyTempTrueN , 'r', 'linewidth', 1.5);  
sumPlt   = plot(newBreaks, eachPenaltyTempTotN  , 'k', 'linewidth', 1.5); 
xlabel('Independent variable cutoff'); 
ylabel('Penalty normalized'); 

yyaxis right
thisax.YAxis(1).Color = 'k';
thisax.YAxis(2).Color = 'k';
ylabel('num')
plot(newBreaks, numFalse, '--b'); 
plot(newBreaks, numTrue, '--r'); 

legend([falsePlt, truePlt, sumPlt], {'Greater than', 'Less than', 'Total Penalty'}, 'Location', 'best'); 

% %%% If you want to see the optimal division threshold, just uncomment this
% %%% couple of lines. 
% [minPen, ipenBreak] = min(eachPenaltyTempTotN); 
% sprintf([newline newline newline...
%     'For optimized dataset (water?) on %s, optimal split value (depth?) = %1.0f'...
%     newline newline newline], ...
%     '???', newBreaks(ipenBreak))

% ylim([0 10]); 
% exportgraphics(gcf, 'Figures/manual_sep/cutoffNormalized.pdf'); 
end

if options.showPlot145; 
    pltClrs = {'blue', [148, 76, 0]./255, 'black'}; 
    figure(145); hold on; 
    sumPlt = plot(newBreaks, eachPenaltyTempTotN  , 'k', 'linewidth', 1.5,...
        'DisplayName', options.optimPlotStruct.thisSplit, ...
        'color', pltClrs{options.optimPlotStruct.ind} ); 
%     legend(sumPlt, options.optimPlotStruct.thisSplit); 
    LGD = legend(); 
    LGD.Location = 'best'; 
    
    [minPen, ipenBreak] = min(eachPenaltyTempTotN); 
%     penBreakBest = newBreaks(ipenBreak); 
%     cutInd = penBreakBest; 
    minPenScat = scatter(newBreaks(ipenBreak), ...
            eachPenaltyTempTotN(ipenBreak), 80, 'ok', 'linewidth', 2, ...
            'HandleVisibility', 'off',...
            'MarkerEdgeColor', pltClrs{options.optimPlotStruct.ind} ); 
    
    sprintf([newline newline newline...
        'For optimized dataset (water?) on %s, optimal split value (depth?) = %1.0f'...
        newline newline newline], ...
        options.optimPlotStruct.thisSplit, newBreaks(ipenBreak))

%     title(options.optimPlotStruct.title, 'fontweight', 'normal'); 
    xlabel(options.optimPlotStruct.xlabel); 
    ylabel('Penalty (\circ)')
    box on; 
    grid ON; 
    set(gca,'XMinorTick','on')
        
end

end