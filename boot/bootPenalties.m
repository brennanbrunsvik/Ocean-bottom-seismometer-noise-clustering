function [bootInfo] = bootPenalties(bootBools, dat, fnew, penaltyFunction, penaltyActual);
showBootPlot = true; % Should put this as argument somewhere probably. 
NStraps = 10000; % Number of bootstrap-like iterations

Nspectra = length(bootBools{1});
Nclusts   = length(bootBools); 

permuteNValues = [2, 5, floor([1/20, 1/8, 1/2, 1] .* Nspectra)]; % Using something automatic like this in case the number of input spectra changes. 
% permuteNValues = [Nspectra]; % Using something automatic like this in case the number of input spectra changes. 


bootPen = nan(NStraps, length(permuteNValues));  % shape = (each bootstrap like analisis, by each number of permuted values)
for ithisPermuteN = 1:length(permuteNValues); 
thisPermuteN = permuteNValues(ithisPermuteN); 
parfor istrap = [1:NStraps]; 
    
    % Randomly select thisPermuteN spectra and swap them. Tricky code, but
    % should be fast and is generic in handling all or partial array swaps. 
    newIndex = [1:Nspectra]; % Indecies routing old spectra to new spectra
    allPerm = randperm(Nspectra); % Trick to get Nspectra unique integers from 1<= <=Nspectra
    toSwap = allPerm(1:thisPermuteN); % Nspectra unique integers from 1<= <=Nspectra
    howSwap = randperm(thisPermuteN); % Which order will we swap the indicies which we want to swap % Does allow 1 spectra to not change sometimes (as should)
    newIndex(toSwap) = toSwap(howSwap); % Actually swap the indicies. 
    % Can verify that it worked. unique(newIndex);     eachPen = nan(Nclusts,1); 
    %     eachNewBool = {}; % Should remove this later for speed TODO
    
    eachPen = nan(Nclusts,1); 
    for ibool = 1:length(bootBools); 
        newInds = newIndex(bootBools{ibool}); % rerout the previous bool to look at scatter spectra
        newBool = logical(zeros(Nspectra,1)); 
        newBool(newInds) = true; % Use disp to see the number of true elements in each new bool. Should, and does, sume to same number as was in original bools.
        eachPen(ibool) = cluster_spread(dat(newBool,:), fnew, '', nan, ...
                                showPlot=false, penalty=penaltyFunction); 
%         eachNewBool{ibool} = newBool; % Remove this later for speed TODO
    end
    bootPen(istrap, ithisPermuteN) = sum(eachPen); 
end
 
% Calculate some stats from the boot like analysis
stdb = std(bootPen,1); 
meanb = mean(bootPen,1); 
medb = median(bootPen,1); 
stdDist = (meanb-penaltyActual)./stdb; % Number of standard deviations away from mean for true penalty

end


if showBootPlot; 
        
    unClustPen = cluster_spread(dat, fnew, '', nan, ...
                        showPlot=false, penalty=penaltyFunction);
                    
                    
                
    figure(300); set(gcf, 'pos', [-1129 281 842 731]); clf; hold on; 
    pltN = 3; pltM = 3; 
    for ithisPermuteN = 1:length(permuteNValues); 
        thisBootPen = bootPen(:,ithisPermuteN); 
        thisBootPenAv = mean(thisBootPen); 
        
        % Get penalty where 95% of penalties are higher. 
        pSort = sort(thisBootPen); 
        perc95 = pSort( floor(length(pSort).*.05) ); % 95 percent of penalties were higher than this. 
        penRed_perc95 = -(perc95-unClustPen)/unClustPen .* 100; 
        penRedActual = -(penaltyActual - unClustPen) / unClustPen .* 100; 
        penAvRed = -(meanb - unClustPen) / unClustPen .* 100; 
        sprintf('With %1.0f permuted spectra, penalty reduction beneath which 95%% of random groupings fell: %1.2f%%',...
            permuteNValues(ithisPermuteN), penRed_perc95)
        
        subplot(pltM, pltN, ithisPermuteN); hold on; 
        H1 = histogram(thisBootPen,35); % ./penOrig.*100, 100); 
        H1.Normalization = 'probability';
        xlabel('Penalty permuted (\circ)'); 
        ylabel('Probability of penalty'); 
        
        ylim(gca(), get(gca, 'YLim')); 
        plot([meanb(ithisPermuteN), meanb(ithisPermuteN)],...
            [0, 1], '-', 'Color', 'k', 'linewidth', 2); 
        plot([perc95, perc95], [0, 1],...
            '-', 'Color', [34, 168, 13]./255, 'linewidth', 2); 
        
%         ylimTxt = get(gca,'ylim');
%         xlimTxt = get(gca,'xlim'); 
%         text(xlimTxt(1),ylimTxt(2),...
%             'stuff')
%         thisTxt = text(0.04, 1-0.05, ... % 0.05, 0.85, ...
%             sprintf('\\mu = %1.0f%c\n\\sigma = %1.1f%c\nZ = %1.1f', ...
%                 meanb(ithisPermuteN), ...
%                 char(176),...
%                 stdb(ithisPermuteN),...
%                 char(176),...
%                 stdDist(ithisPermuteN) ),...
%             'units', 'normalized', ...
%             'EdgeColor', 'k', 'BackgroundColor', 0.98 .* [1 1 1],... 
%             'horizontalalignment', 'left', 'verticalalignment', 'top'); 
        thisTxt = text(0.04, 1-0.05, ... % 0.05, 0.85, ...
            sprintf('\\sigma = %1.1f%c\nZ = %1.1f', ...
                stdb(ithisPermuteN),...
                char(176),...
                stdDist(ithisPermuteN) ),...
            'units', 'normalized', ...
            'EdgeColor', 'k', 'BackgroundColor', 0.98 .* [1 1 1],... 
            'horizontalalignment', 'left', 'verticalalignment', 'top'); 
        
        title(sprintf('%1.0f spectra permuted', permuteNValues(ithisPermuteN)), ...
            'fontweight', 'normal'); 
        box on; 
        
%         if permuteNValues(ithisPermuteN) == size(dat,1); % if all values were permuted
        % Plot unclustered penalty. Don't change axix limits though. 
        thisXlim = xlim; 
        xlim(thisXlim); 
        plot([unClustPen, unClustPen], [0, 1], ...
            '-', 'color', [166, 90, 15]./255, 'linewidth', 2); 
%     end
%     exportgraphics(gcf, 'FIGURES/penalty_random_clusters_1_or_3_layer.png',...
%         'resolution', 500); 

    set(gca,'Layer','top'); % Axis stuff plots above histogram    
    end
    sgtitle(sprintf('Actual penalty: %1.0f, %0.1f%%, unclust penalty: %1.0f, bootPenAv: %1.0f, %0.3f%%,\n95%% confidence: %1.0f, %0.3f%%\n',...
    penaltyActual, penRedActual, unClustPen, thisBootPenAv, penAvRed, perc95, penRed_perc95)); 
    exportgraphics(gcf, 'FIGURES/penalty_random_clusters_1_or_3_layer.pdf'); 

end



% %%% just a test to make sure I got the right boot bools, and that I made
% %%% good boot bools. 
% eachPenReal = nan(Nclusts,1); 
% for ibool = 1:length(bootBools); 
%     eachPenReal(ibool) = cluster_spread(dat(bootBools{ibool},:), fnew, '', nan, ...
%                             showPlot=false, penalty=penaltyFunction); 
% end
% recalcRealPen = sum(eachPenReal); 
% 
% 
% % See whic bool each index was assigned to. 
% whichBoolNew = nan(size(dat,1),1); 
% whichBoolReal = nan(size(dat,1),1); 
% for ibool = [1:Nclusts]; 
%     whichBoolReal(bootBools      {ibool})=ibool; 
%     whichBoolNew (eachNewBool    {ibool})=ibool; 
% end
% 



% figure(301); clf; hold on; 
% subplot(1,2,1); 
% histogram(whichBoolReal); 
% title('Real clusters'); 
% subplot(1,2,2); 
% histogram(whichBoolNew); 
% title('Randomized'); 
% xlabel('Which cluster'); 
% ylabel('Num in cluster'); 
% sgtitle('Number of spectra in each cluster'); 

% Make sure the original booleans represented each station only once. Else
% we would get lowered spread. 
% countSta = zeros(Nspectra, 1); 
% for ibool = 1:Nclusts; 
%     countSta(bootBools{ibool}) = countSta(bootBools{ibool}) + 1; 
% end
% unique(countSta)
% sum(countSta)