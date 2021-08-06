% Right now you need to run on of the cluster_break....m files before
% running this, just to get correct variables loaded. 

% Use R2 analysis to figure out how important each independent variable is.
% 

residRemove = predictor_importance_r2(OthVarMat', dat); 
%% 
labelsNums = {''; 'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current'; ''}; 
figure(4); clf; hold on; 
barh(residRemove)
set(gca, 'yticklabel', labelsNums)

title('r^2 with given data type missing (SMALLER means MORE important)'); 
xlabel('r^2'); 

box on; 

exportgraphics(gcf, 'FIGURES/r2/r2.pdf'); 

%% Now try to add in categorical data

% cats(7).data = stavec(gind);
% suff{7} = 'OBS Design';
% cats(8).data = smtvec(gind);
% suff{8} = 'Seismometer';
% cats(9).data = prsvec(gind);
% suff{9} = 'Pressure Gauge';
% cats(10).data = envvec(gind);
% suff{10} = 'Environment';
% cats(11).data = expvec(gind);
% suff{11} = 'Experiment';

catsNum = zeros(5, size(OthVarMat, 2)); 
skip = size(OthVarMat, 1); 
for icat = [1:size(catsNum, 1)]; 
    [c1, ia1, ic1] = unique(cats(icat+skip).data ); 
    catsNum(icat,:) = ic1.^2; 
end

% residRemove = nan( size(catsNum, 1), 1); 
% for idat = [1:size(catsNum, 1)]; 
%     keep = ones(size(catsNum, 1), 1);
%     keep(idat) = 0; 
%     keep = logical(keep); 
%     
%     [beta, sigma, resid] = mvregress(catsNum(keep, :)', dat);
%     resid2 = rms(resid, 'all')^2; 
%     residRemove(idat) = resid2; 
% end
residRemove = predictor_importance_r2(catsNum', dat)

%% 
% labels = {''; 'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
%             'Crustal Age'; 'Sediment Thickn'; 'Surface Current'; ''}; 
labelsCats = {''; 'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'; ''}; 
figure(5); clf; hold on; 
barh(residRemove)
set(gca, 'yticklabel', labelsCats)

title('r^2 with given data type missing (larger means more important)'); 
xlabel('r^2'); 

box on; 

exportgraphics(gcf, 'FIGURES/r2/r2cats.pdf'); 


%% Now see if we can merge all together. 

allPredictors = [OthVarMat; catsNum]; 

residRemove = nan( size(allPredictors, 1), 1); 
for idat = [1:size(allPredictors, 1)]; 
    keep = ones(size(allPredictors, 1), 1);
    keep(idat) = 0; 
    keep = logical(keep); 
    
    [beta, sigma, resid] = mvregress(allPredictors(keep, :)', dat);
    resid2 = rms(resid, 'all')^2; 
    residRemove(idat) = resid2; 
end

%% Plot all 

labelsAll = {''; 'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment';''}; 
% labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
%             'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
%             'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 
figure(6); clf; hold on; 
barh(residRemove)
% set(gca, 'yticklabel', labelsAll)
for itxt = [0:length(labelsAll)-1]; 
    text(0, itxt, labelsAll{itxt+1}); 
end

title('r^2 with given data type missing (larger means more important)'); 
xlabel('r^2'); 

box on; 

exportgraphics(gcf, 'FIGURES/r2/r2All.pdf'); 