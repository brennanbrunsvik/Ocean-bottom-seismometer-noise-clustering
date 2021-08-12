% clear; 
% close all; 
sameStasAllAnalyses = true; 
showSpectrograms = false; 
showPenalOptim = false; 
penaltyFunction = 'spectral_angle'; 
coh_or_spec = 'spec'; % coherance (coh) or spectra (spec)
% datswitch = 1; % Look in prep data
% component = 1; % Look in prep data

datcomp = [...
    1,1;...
    1,2;...
%     1,3 ...
    ];

for idatcomp = [1]; 
% for idatcomp = [1:size(datcomp, 1)]; 

% for iquant = [2]; 
eachPenalty = zeros(size(labelsAll,1), 1); 
for iquant = [1:length(labelsAll)]; % Slower to put the loop so high up in code, but makes it easier to think and develop the code. 

OBS_TableParams;
if strcmp(coh_or_spec, 'coh'); 
    prep_data_coh; 
else
    prep_data; 
end

datswitch = datcomp(idatcomp, 1); 
component = datcomp(idatcomp, 2); 

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

labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 
% % for iquant = [2]; 
% for iquant = [1:length(labelsAll)]; 


cut1 = 'Instrument'; 
cut2 = 'Water'; 
cut3 = labelsAll{iquant}; 

tempDat = mergedData(iquant); 
tempDat = tempDat{1}; 
dataSets = struct('data1', string(cats(8).data), ...
                  'data2', OthVarMat(1,:), ...
                  'data3', tempDat); 

% shallow =  ( OthVarMat(1,:) < cut1 )'; 
% seismom = ( string(cats(8).data) ==  cut2)';
% seismom(:) = nan; % Don't want seismom anymore. 
% environment = ( string(cats(10).data) == cut3)'; 

% Handle the third dataset. Break into each category. 
if isCat(iquant); 
    eachTempDat = unique(tempDat); 
    tempDatBools = {}; 
    for iUniqueDat = [1:length(eachTempDat)]; 
        tempDatBools{iUniqueDat} = tempDat' == eachTempDat(iUniqueDat); 
    end
    namesAdd = cellstr(eachTempDat); 
else
    namesAdd = {[cut3 '<'], [cut3 '>=']};
    tempDatBools = {"Turn on", "optimization for depth 3"}; 
end

bools = {... % Data 1
           {(string(cats(8).data)=="Trillium 240")', ...
            (string(cats(8).data)=="Guralp CMG3T 120")', ...
            (string(cats(8).data)=="Trillium Compact")'}, ...    
        ... % Data 2
            { OthVarMat(1,:)' < 220, ...
              and(OthVarMat(1,:)' >=220, OthVarMat(1,:)' <4160),...
              OthVarMat(1,:)' >=4160}, ...
        ... % Data 3
           tempDatBools}; 
boolsMult = {}; 
names = {
    {'Trillium 240', 'Guralp CMG3T 120', 'Trillium Compact'},... % Names 1
    {'Shallow', 'Deep'},... % Names 2
     namesAdd,...%}... % Names 3
    }; 


% MANUAL important
% Determin how many splits (branches) there are in each layer. 
% For quantitative data with nans in it, add another split to assess the
% spread of the nan data. 
% For quantititative data with nanes in it, add an 'Unspecified' name
splits = [3, 2, 2]; 
if ~isnumeric(dataSets.data3); 
    splits(3) = length(unique(dataSets.data3)); 
end
if isnumeric(dataSets.data1) && any(isnan(dataSets.data1)); 
    splits(1) = splits(1)+1; names{1}{splits(1)} = 'Unspecified'; end
if isnumeric(dataSets.data2) && any(isnan(dataSets.data2)); 
    splits(2) = splits(2)+1; names{2}{splits(2)} = 'Unspecified'; end
if isnumeric(dataSets.data3) && any(isnan(dataSets.data3)); 
    splits(3) = splits(3)+1; names{3}{splits(3)} = 'Unspecified'; end   
if splits(2) == 0; cut2 = ''; end 
if splits(3) == 0; cut3 = ''; end


loopOptimizePenalty = [ false true true ] ; 
if isCat(iquant); % Can't really loop through categories. The loop is over a quantitative variable...
    loopOptimizePenalty(3) = false; 
end

% figure(11); clf; hold on; plot(dat'); 

%% Automated algorithm to create a dendrogram type thingy of our clusters. 

% First get whole dataset
figure(2); clf; set(gcf, 'pos', [2731 1103 496 401]); 
thisax = nan; % Just need to pass ax object to some functions even if it isn't used. 
penalty = cluster_spread(dat, fnew, 'All data', gca, showPlot=true, penalty=penaltyFunction);

penaltiesi   = {}; 
penaltiesij  = {}; 
penaltiesijk = {}; 
penalties = {}; % Penalties. How to access? penalties{1}{i}; penalties{2}{i,j}; penalties{3}{i,j,k}; 

figure(12); clf; hold on; set(gcf, 'pos', [1601 1609 1846 388]); % Dendrogram figure
% figure(132); clf; hold on; set(gcf, 'pos', [2017 342 1767 1656]); % Figure to hold a bunch of spectra and other things
figure(132); clf; hold on; set(gcf, 'pos', [2017 342 2767 1656]); % Figure to hold a bunch of spectra and other things
pltn = 5; pltm = 7; % rows by collumns of main plot
thissubplot = 1; 
% figure(133); clf; hold on; set(gcf, 'pos', [2609 485 1175 1513]); % Figure to hold a bunch of penalty curves


% Start the main loop. 
for i = [1:splits(1)]; % First level
for j = [0:splits(2)]; % Second level
for k = [0:splits(3)]; % Third level

if (j<1) & (k>0); continue; end % Doesn't make any sense to split the third layer and not the second. Algorithm breaks without this

[thissubplot, thisname, thisbool, penBreakBest] = clusterAtHierarchy(loopOptimizePenalty, 'i', i, j,...
    thissubplot, pltn, pltm, dataSets.data1, ...
    dat, fnew, penaltyFunction, showPenalOptim, bools, names); 

if j > 0; % Execute this code if we are going in 2 deep. Combine the name and boolean for our second "layer". e.g. "shallow + seismometer = T240"

    [thissubplot, thisname, thisbool, penBreakBest] = clusterAtHierarchy(loopOptimizePenalty, 'j', j, k,...
        thissubplot, pltn, pltm, dataSets.data2, ...
        dat, fnew, penaltyFunction, showPenalOptim, bools, names, ...
        thisname=thisname, thisbool=thisbool);

    if k > 0; % Execute this code if we are going in 3 deep. 
        [thissubplot, thisname, thisbool, penBreakBest] = clusterAtHierarchy(loopOptimizePenalty, 'k', k, 0,...
            thissubplot, pltn, pltm, dataSets.data3, ...
            dat, fnew, penaltyFunction, showPenalOptim, bools, names, ...
            thisname=thisname, thisbool=thisbool);

%         thisname = [thisname '\newline' names{3}{k}]; 
%         thisbool = and(thisbool, bools{3}{k}); 
    end
end

% disp(sprintf('%s %1.0f %1.0f %1.0f', thisname, i, j, k) ) % What thing did we just analyze, and what were the indecies? 
thiscluster = dat(thisbool, :); % Select the cluster

% if sum(thisbool) == 0; 
%     continue; 
% end

if showSpectrograms; 
    figure(132); 
    thisax = subplot(pltn, pltm,  thissubplot); thissubplot = thissubplot + 1; % On Figure 132  
else; 
    thisax = nan; 
end
penalty = cluster_spread(thiscluster, fnew, replace(thisname, '\newline', '|'), thisax, ...
    showPlot=showSpectrograms, penalty=penaltyFunction); % Main thing! What is the penalty for this cluster? 
numdat = sum(thisbool); 
thisname = [thisname sprintf('\\newlineP=%1.0f, n=%3.0f, P/n=%3.1f', penalty, numdat, penalty/numdat) ]; % Add penalty to the name so we can visualize. 

if k > 0; 
    penaltiesijk{i}{j}{k} = penalty; 
elseif j > 0; 
    penaltiesij{i}{j} = penalty; 
else; 
    penaltiesi{i} = penalty; 
end

%%% This section just for visualizing. 
y = 0; x = 0; 
if i > 0; y = y - 1; end 
if j > 0; y = y - 1; end 
if k > 0; y = y - 1; end

% x = (i-1.5) * 1; 
% if j > 0; 
%     x = x + (j-1.5) ./ splits(2); 
%     if k > 0; 
%         x = x + (k-1.5) ./ splits(3); 
%     end
% end

% posibX = linspace(-1, 1, splits(1))/splits(1); 
% posibX = linspace(-.5, .5, splits(1))/splits(1); 
% x = posibX(i); 
% if j >= 1; 
% %     posibX = linspace(-1, 1, splits(2))/(splits(2)+1)/splits(1); 
%     posibX = linspace(-.5, .5, splits(2))/(splits(2)+2)/splits(1); 
%     x = x + posibX(j); 
% end
% if k >= 1; 
% %     posibX = linspace(-1, 1, splits(3))/(splits(3)+1)/splits(2)/splits(1); 
% %     posibX = linspace(-2, 2, splits(3))/(splits(3)+2)/splits(2)/splits(1); % Don't fully understand why [-2, 2] works...
%     posibX = linspace(-1, 1, splits(3))/(splits(3)+2)/splits(2)/splits(1); % Don't fully understand why [-2, 2] works...
% 
%     x = x + posibX(k); 
% end

posibX = linspace(-.5, .5, splits(1)); 
x = posibX(i); 
if j >= 1; 
%     posibX = linspace(-1, 1, splits(2))/(splits(2)+1)/splits(1); 
    posibX = linspace(-.5, .5, splits(2))/(splits(1)) .* .8; 
    x = x + posibX(j); 
end
if k >= 1; 
%     posibX = linspace(-1, 1, splits(3))/(splits(3)+1)/splits(2)/splits(1); 
%     posibX = linspace(-2, 2, splits(3))/(splits(3)+2)/splits(2)/splits(1); % Don't fully understand why [-2, 2] works...
    posibX = linspace(-.5, .5, splits(3))/splits(2)/splits(1) .* 1; % Don't fully understand why [-2, 2] works...

    x = x + posibX(k); 
end

figure(12); 
scatter(x, y, .01); 

%Get minimum amount of text needed to describe a cluster. such a PITA
%without being able to do names{3}(k){1}, like I can in Python. 
if k > 0; 
    tempNames = names{3}; 
    thisText = tempNames(k); 
    thisText = thisText{1}; 
    if loopOptimizePenalty(3); 
        thisText = [thisText sprintf('%1.2f', penBreakBest) '\newline']; % Only give new line for third depth if doing optimization. Not categories. Too many categories...
    end
elseif j > 0; 
    tempNames = names{2}; 
    thisText = tempNames(j); 
    thisText = thisText{1}; 
    if loopOptimizePenalty(2); 
        thisText = [thisText ' ' sprintf('%1.2f', penBreakBest)]; 
    end
    thisText = [thisText '\newline'] % Always give new line for second depth. 
else; 
    tempNames = names{1}; 
    thisText = tempNames{i}; 
    thisText = [thisText '\newline']; 
%     thisText = thisText{1}; % Not sure why but I need to comment this
%     out? 
end
% thisText  = sprintf('%s n=%3.0f, P/n=%2.2f', thisText, numdat, penalty/numdat); 
thisText = [thisText sprintf('n=%3.0f, P/n=%2.2f',numdat, penalty/numdat)];  % Can't just use sprintf over the whole thing. Else \newline will be erased. How obnoxious. 

% thistxt = text(x, y, thisname, 'Rotation', 0, 'HorizontalAlignment', 'center'); 
textPlot = text(x, y, thisText, 'Rotation', 37, 'HorizontalAlignment', 'center'); 

%%%

end
end
end

% % More plot stuff
% cxlim = get(gca, 'xlim'); 
% cylim = get(gca, 'ylim'); 
% xlim([cxlim(1)-1, cxlim(2)+1]); 
% ylim([cylim(1)-1, cylim(2)+1]); 


% Sum up penalties accross layers. 
penaltyTi = 0; 
penaltyTij = 0; 
penaltyTijk = 0; 
% Now sum penalties accross levels...
for i = [1:splits(1)]; % First level
for j = [0:splits(2)]; % Second level
for k = [0:splits(3)]; % Third level
%     k = 0; 
if (j<1) & (k>0); continue; end % Doesn't make any sense to split the third layer and not the second. Algorithm breaks without this
if j < 1; % Only on first layer
    penaltyTi = nansum([penaltyTi , penaltiesi{i}]); 
end
if (j > 0) & (k < 1); 
    penaltyTij = nansum([penaltyTij , penaltiesij{i}{j}]); % 2021.08.10 will need to put this line in any similar codes, due to making N=1,0 clusters have NaN spread and not 0 and Inf.  
end
if k > 0; 
%     disp(penaltiesijk{i}{j}{k})
    penaltyTijk = nansum([penaltyTijk , penaltiesijk{i}{j}{k}]); 
end % end if statment
end % end k
end % end j 
end % end i



figure(12); 
% Plot the penalties. 
axis off; 
xtxt = get(gca, 'xlim'); 
xtxt = xtxt(1); 
% scatter(xtxt, -1); 
text(xtxt, -1, sprintf('Tot P=%6.0f', penaltyTi  ), 'HorizontalAlignment', 'right'); 
text(xtxt, -2, sprintf('Tot P=%6.0f', penaltyTij ), 'HorizontalAlignment', 'right'); 
if splits(3) > 0; 
    text(xtxt, -3, sprintf('Tot P=%6.0f', penaltyTijk), 'HorizontalAlignment', 'right'); 
end

title(sprintf('%s, Datswitch=%1.0f, Component=%1.0f, %s -> %s -> %s', coh_or_spec, datswitch, component, cut1, cut2, cut3) ); 

ylim([-3.5, 0]); 
% xlim([-.275, .275]); 
xlim([-1, 1]); 

textFig = sprintf('%s_Datswitch%1.0f_Comp%1.0f-%s-%s-%s', coh_or_spec, datswitch, component, cut1, cut2, cut3);  
exportgraphics(figure(12), sprintf('Figures/dendrogram__%s.pdf', textFig)); 
exportgraphics(figure(132),sprintf('Figures/manual_sep/combined__%s.pdf', textFig)); 

eachPenalty(iquant) = penaltyTijk; 

end
end

finPenFile = sprintf('pen_results/penalties_%s_datswitch%1.0f_component%1.0f_3layer.mat',...
    coh_or_spec, datswitch, component); 
save(finPenFile, 'eachPenalty'); 


% Can plot histogram of final penalty, based on each third hierarchy depth
figure(70); clf; hold on; 
barh(eachPenalty)

set(gca, 'yticklabel', labelsAll)
for itxt = [1:length(labelsAll)]; 
    text(0, itxt, labelsAll{itxt}); 
end

xlabel('Penalty using this variable as third hierarchy depth'); 
set(gca, 'ytick', []); 

box on; 
grid on; 

exportgraphics(gcf, 'FIGURES/third_var_clusters_bar.pdf'); 



