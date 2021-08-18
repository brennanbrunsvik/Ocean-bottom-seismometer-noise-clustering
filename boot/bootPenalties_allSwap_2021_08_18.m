function [bootInfo] = bootPenalties(bootBools, dat, fnew, penaltyFunction, penaltyActual);
showBootPlot = true; % Should put this as argument somewhere probably. 

NStraps = 100; % Number of bootstrap-like iterations

Nspectra = length(bootBools{1});
Nclusts   = length(bootBools); 

bootPen = nan(NStraps, 1); 
for istrap = [1:NStraps]; 
    clustInds = randperm(Nspectra); 
    eachPen = nan(Nclusts,1); 
%     eachNewBool = {}; % Should remove this later for speed TODO
    for ibool = 1:length(bootBools); 
        newInds = clustInds(bootBools{ibool}); % rerout the previous bool to look at scatter spectra
        newBool = logical(zeros(Nspectra,1)); 
        newBool(newInds) = true; % Use disp to see the number of true elements in each new bool. Should, and does, sume to same number as was in original bools.
        eachPen(ibool) = cluster_spread(dat(newBool,:), fnew, '', nan, ...
                                showPlot=false, penalty=penaltyFunction); 
%         eachNewBool{ibool} = newBool; % Remove this later for speed TODO
    end
    bootPen(istrap) = sum(eachPen); 
end

if showBootPlot; 
    figure(300); clf; hold on; 
    H1 = histogram(bootPen,100); % ./penOrig.*100, 100); 
    H1.Normalization = 'probability';
%     scatter(penaltyActual, 0, 100, 'yellow', 'filled')
    xlabel('Clustered penalty after permuting spectra'); 
    ylabel('p(penalty)'); 
    title(sprintf('Actual penalty: %5.2f', penaltyActual)); 
    saveas(gcf, 'FIGURES/penalty_random_clusters_1_or_3_layer.png'); 
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