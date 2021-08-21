function [penaltyTijk, penaltyTij, penaltyTi, penaltyUnClust] = clusterWholeHierarchy(sameStasAllAnalyses, ...
    showSpectrograms, showPenalOptim, penaltyFunction, ...
    coh_or_spec, datswitch, component, iquant); 



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

labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 




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
    namesAdd = {['<'], ['>=']};
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
    {'<', '>='},... % Names 2
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

if showSpectrograms; 
figure(2); clf; set(gcf, 'pos', [2731 1103 496 401]); 
figure(12); clf; hold on; set(gcf, 'pos', [1601 1609 1846 388]); % Dendrogram figure
figure(132); clf; hold on; set(gcf, 'pos', [2017 342 2767 1656]); % Figure to hold a bunch of spectra and other things
figure(134); clf; hold on; set(gcf, 'pos', [-1196 247 931 931]); % Experimental figure to combine dendrogram and spectra plots. 
ax134 = gca(); 
set(ax134, 'Units','Normalize','Position',[0 0 1 1]); % Make it so figure coordinates and data coordinates are the same. 
xlim([0, 1]); ylim([0, 1]); 
axis off;
end
pltn = 5; pltm = 7; % rows by collumns of main plot
thissubplot = 1; 



% thisax = nan; % Just need to pass ax object to some functions even if it isn't used. 
penaltyUnClust = cluster_spread(dat, fnew, 'All data', nan, showPlot=false, penalty=penaltyFunction);

penaltiesi   = {}; 
penaltiesij  = {}; 
penaltiesijk = {}; 
penalties = {}; % Penalties. How to access? penalties{1}{i}; penalties{2}{i,j}; penalties{3}{i,j,k}; 
bootBools = {}; % for Bootstrap like analysis. Keep each of the final bools. Mostly just so I know how many things are in each final cluster. 


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
        bootBools{end+1} = thisbool; 

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

if showSpectrograms; 
    [x, y] = ijkToAxPos(i,j,k,splits(1),splits(2),splits(3)); % Get position to plot in dendrogram
    figure(12); 
    scatter(x, y, .01); 

    %Get minimum amount of text needed to describe a cluster. such a PITA
    %without being able to do names{3}(k){1}, like I can in Python. 
    if k > 0; 
        tempNames = names{3}; 
        thisText = tempNames(k); 
        thisText = thisText{1}; 
        if loopOptimizePenalty(3); 
            thisText = [thisText sprintf('%1.2f', penBreakBest) newline]; % Only give new line for third depth if doing optimization. Not categories. Too many categories...
        end
    elseif j > 0; 
        tempNames = names{2}; 
        thisText = tempNames(j); 
        thisText = thisText{1}; 
        if loopOptimizePenalty(2); 
            thisText = [thisText ' ' sprintf('%1.2f', penBreakBest)]; 
        end
        thisText = [thisText newline]; % Always give new line for second depth. 
    else; 
        tempNames = names{1}; 
        thisText = tempNames{i}; 
        thisText = [thisText newline]; 
    %     thisText = thisText{1}; % Not sure why but I need to comment this
    %     out? 
    end
    % thisText  = sprintf('%s n=%3.0f, P/n=%2.2f', thisText, numdat, penalty/numdat); 
    thisText = [thisText sprintf(['Pav=%1.0f' newline 'n=%1.0f'], penalty/numdat, numdat)];  % Can't just use sprintf over the whole thing. Else \newline will be erased. How obnoxious. 
    % thistxt = text(x, y, thisname, 'Rotation', 0, 'HorizontalAlignment', 'center'); 
    textPlot = text(x, y, thisText, 'Rotation', 37, 'HorizontalAlignment', 'center'); 
    
    figure(134); % Dendrogram + spectrogram figure
    [xInset, yInset, widthIns, heightIns] = ijkToAxPos3(i,j,k,splits(1),splits(2),splits(3)); % Get position to plot in dendrogram
     
    axIns = axes('Position', [xInset-.5*widthIns, yInset-.5*heightIns, widthIns, heightIns]); 
    [~] = cluster_spread(thiscluster, fnew, replace(thisname, '\newline', '|'), axIns, ...
        showPlot=true, penalty=penaltyFunction, barePlot=true); % Just using this to plot spectra cluster again. 
    if (j<1) & (k<1); 
        grid on; 
        if i > 1; 
            xticklabels([]); yticklabels([]); 
%             thisMinX = xlim(); 
%             thisMinX = thisMinX(1); 
%             text(thisMinX + diff(xlim()) * .02, ...
%                 mean(ylim()), 'dB'); 
        else; 
            xticklabels([]); 
        end
        if i == 2; % Add frequency labels, inside plot and not beneath
            thisMinY = ylim(); 
            thisMinY = thisMinY(1); 
            text([0.01, 0.1],...
                [thisMinY, thisMinY] + diff(ylim())/20,...
                {'0.01 Hz', '0.1 Hz'}, ...
                'horizontalAlignment', 'center'); 
        end
    else; 
        xticks([]); yticks([]); 
    end
    %     textPlot = text(gca, 0.025, 0.975, thisText, 'units', 'normalized', 'verticalalignment', 'top'); 
    thisTitle = title(thisText, 'FontWeight', 'normal'); 
    dendroConnectLines(ax134, i, j, k, splits); 
    % Only modify the top level plots of 134 to add labels and stuff. 
    
end
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

%%% bootstrap like analysis

%
if false; % TODO add an option to or not to do this. It takes a lot of computational time. 
bootPenalties(bootBools, dat, fnew, penaltyFunction, penaltyTijk); 
end

if showSpectrograms; % show spectrograms sort of morphed into plot anything. 
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


    axes(ax134); % Dendrogram + spectrogram figure 
    xTxt = 0.04 
    pred1 = (1-penaltyTi  /penaltyUnClust)*100; 
    pred2 = (1-penaltyTij /penaltyUnClust)*100; 
    pred3 = (1-penaltyTijk/penaltyUnClust)*100; 
    predDiff = diff([0, pred1, pred2, pred3]); % Show gain in reduction from previous level
    [~, yTxt, ~, ~] = ijkToAxPos3(1,0,0,splits(1),splits(2),splits(3)); % Get position to plot things on left   
    text(xTxt, yTxt, ...
        [sprintf('%s\nPtot = %1.0f\nPred = %1.0f', cut1, penaltyTi, predDiff(1)) '%'],...
        'HorizontalAlignment', 'center'); 
    [~, yTxt, ~, ~] = ijkToAxPos3(1,1,0,splits(1),splits(2),splits(3)); 
    text(xTxt, yTxt, ...
        [sprintf('%s\nPtot = %1.0f\nPred = %1.0f', cut2, penaltyTij, predDiff(2)) '%'],...
        'HorizontalAlignment', 'center'); 
    [~, yTxt, ~, ~] = ijkToAxPos3(1,1,1,splits(1),splits(2),splits(3)); 
    text(xTxt, yTxt, ...
        [sprintf('%s\nPtot = %1.0f\nPred = %1.0f', cut3, penaltyTijk, predDiff(3)) '%'],...
        'HorizontalAlignment', 'center'); 
    
    uistack(ax134, 'bottom');

    % Save all the figs. 
    textFig = sprintf('%s_Datswitch%1.0f_Comp%1.0f-%s-%s-%s', coh_or_spec, datswitch, component, cut1, cut2, cut3);  
    exportgraphics(figure(12), sprintf('Figures/dendrogram__%s.pdf', textFig)); 
    exportgraphics(figure(132),sprintf('Figures/manual_sep/combined__%s.pdf', textFig));
    exportgraphics(figure(134), sprintf('Figures/dendrogram_spec__%s.pdf', textFig),...
        'contentType', 'vector'); 

end 

end
