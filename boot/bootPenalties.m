function [bootInfo] = bootPenalties(bootBools, dat, fnew, penaltyFunction, penaltyActual);
showBootPlot = true; % Should put this as argument somewhere probably. 
NStraps = 1000; % Number of bootstrap-like iterations

Nspectra = length(bootBools{1});
Nclusts   = length(bootBools); 

permuteNValues = [2, 5, floor([1/20, 1/8, 1/2, 1] .* Nspectra)]; % Using something automatic like this in case the number of input spectra changes. 

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
    figure(300); set(gcf, 'pos', [-1129 281 842 731]); clf; hold on; 
    sgtitle(sprintf('Actual penalty: %1.0f', penaltyActual)); 
    pltN = 3; pltM = 3; 
    for ithisPermuteN = 1:length(permuteNValues); 
        thisBootPen = bootPen(:,ithisPermuteN); 
        thisBootPenAv = mean(thisBootPen); 
        subplot(pltM, pltN, ithisPermuteN); hold on; 
        H1 = histogram(thisBootPen,100); % ./penOrig.*100, 100); 
        H1.Normalization = 'probability';
        xlabel('Clustered penalty after permuting spectra'); 
        ylabel('p(penalty)'); 
        
        ylim(gca(), get(gca, 'YLim')); 
        plot([meanb(ithisPermuteN), meanb(ithisPermuteN)],...
            [0, 1], '-', 'Color', 'k', 'linewidth', 2); 
        
%         ylimTxt = get(gca,'ylim');
%         xlimTxt = get(gca,'xlim'); 
%         text(xlimTxt(1),ylimTxt(2),...
%             'stuff')
        thisTxt = text(0.05, 0.85, ...
            sprintf('Mean: %1.0f\nSTD: %1.1f\nn*STD: %1.1f', ...
                meanb(ithisPermuteN), ...
                stdb(ithisPermuteN),...
                stdDist(ithisPermuteN) ),...
            'units', 'normalized', ...
            'EdgeColor', 'k', 'BackgroundColor', 0.95 .* [1 1 1] ); 
        
        title(sprintf('Permute %1.0f spectra', permuteNValues(ithisPermuteN))); 
        box on; 
    end
    exportgraphics(gcf, 'FIGURES/penalty_random_clusters_1_or_3_layer.png',...
        'resolution', 300); 
    
end

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