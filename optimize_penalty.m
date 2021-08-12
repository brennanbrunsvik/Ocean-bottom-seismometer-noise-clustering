function [eachPenaltyTempTrue,...
          eachPenaltyTempFalse,...
          eachPenaltyTempTot, ...
          eachPenaltyTempTrueN,...
          eachPenaltyTempFalseN,...
          eachPenaltyTempTotN,...
          newBreaks...
          ] = optimize_penalty(thisData, dat, fnew, penaltyFunction, thisax, showPlot, numCut); 

% thisData = dataSets.data1; 

newBreaks = linspace(min(thisData), max(thisData), numCut); 
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

% ylim([0 10]); 
% exportgraphics(gcf, 'Figures/manual_sep/cutoffNormalized.pdf'); 
end

end