datswitch = 1; 
coh_or_spec = 'spec'; 
component = 1; 
sameStasAllAnalyses = true; 
showSpectraPlots = false; 
randSizes = false; 

numStraps = 4000; 

OBS_TableParams;
prep_data_wrapper; 

if randSizes; 
    stringAdd = 'rand_sizes'; 
else
    stringAdd = 'constant_sizes';
end

penOrig = cluster_spread(dat, fnew, 'allDat', nan, ...
    showPlot=false, penalty='spectral_angle'); 

eachPenClust = zeros(numStraps, 1); 
% parpool(8)
parfor istrap = [1:numStraps]; 

if randSizes; 
    splitInd = randi(size(dat,1)-20)+10; 
else; 
    splitInd = floor(size(dat,1)/2); 
end

% clustInds = [1:size(dat,1)];
clustInds = randperm(size(dat,1)); 
c1Bool = logical(ones(size(dat,1),1)); 
c1Bool(clustInds(1:splitInd)) = false; 
c2Bool = ~c1Bool; 

if showSpectraPlots; 
    figure(1); clf; set(gcf, 'pos', [-692 539 407 263]); hold on; 
    thisax1 = subplot(2,1,1); 
    thisax2 = subplot(2,1,2); 
else; 
    thisax1 = nan; 
    thisax2 = nan; 
end
penalty1 = cluster_spread(dat(c1Bool,:), fnew, 'Random clust 1', thisax1, ...
    showPlot=showSpectraPlots, penalty='spectral_angle'); 

penalty2 = cluster_spread(dat(c2Bool,:), fnew, 'Random clust 2', thisax2, ...
    showPlot=showSpectraPlots, penalty='spectral_angle'); 

penClust = penalty1 + penalty2; 
eachPenClust(istrap) = penClust; 
end

figure(2); clf; hold on; % set(gca, 'pos', [-727 392 410 311]); 

title(sprintf('Penalty total from two random clusters, %s', stringAdd)); 
% histCounts = hist(eachPenClust, 100); 
H1 = histogram(eachPenClust./penOrig.*100, 100); 
H1.Normalization = 'probability';

% scatter(penOrig, 0, 150, 'yellow', 'filled'); 

xlabel('Penalty for two random clusters / original penalty (%)'); 
ylabel('p(N)'); 

box on; 


exportgraphics(gcf, sprintf('../FIGURES/penalty_two_random_clusters_%s.png', stringAdd) ); 