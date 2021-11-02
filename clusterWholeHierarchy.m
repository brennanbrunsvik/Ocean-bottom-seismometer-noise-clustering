function [penaltyTijk, penaltyTij, penaltyTi, penaltyUnClust] = clusterWholeHierarchy(sameStasAllAnalyses, ...
    showSpectrograms, showPenalOptim, penaltyFunction, ...
    coh_or_spec, datswitch, component, iquant); 

try_boot_penalties = false; % Parameter you change. Decide if you want to do the significance analysis or not. 

componentFull = component; % For component = 23, It's going to get changed to 3 (I think). So some figures might be saved with component 3 instead... bb2021.11.01
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

% labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
%             'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
%             'OBS Design'; 'Seismometer'; 'Pressure Gauge'; 'Environment'; 'Experiment'};
load('labelsAll'); 
unitsAll = {' m'; ' km'; ' km'; ...
    ' myr'; ' m'; ' m/s(?)';...
    ''; ''; ''; ''; ''};

unit1 = unitsAll{8};
unit2 = unitsAll{1}; 
unit3 = unitsAll{iquant}; 


cut1 = 'Seismometer'; 
cut2 = 'Depth'; 
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
    namesAdd = {['\leq'], ['\geq']}; % Which one gets geq/leq and which gets > or < is dependent on how we decide on plotting, not on how we seperate the clusters. Because the values plotted actually correspond to max or min values in that cluster.
    tempDatBools = {"Turn on", "optimization for depth 3"}; 
end



bools = {... % Data 1
           {(string(cats(8).data)=="Trillium 240")', ...
            (string(cats(8).data)=="Guralp CMG-3T")', ...
            (string(cats(8).data)=="Trillium Compact")'}, ...    
        ... % Data 2
            { OthVarMat(1,:)' < 220, ...
              and(OthVarMat(1,:)' >=220, OthVarMat(1,:)' <4160),...
              OthVarMat(1,:)' >=4160}, ...
        ... % Data 3
           tempDatBools}; 
boolsMult = {}; 
names = {
    {'Trillium 240', 'Guralp CMG-3T', 'Trillium Compact'},... % Names 1
    {'\leq', '\geq'},... % Names 2 % Which one gets geq/leq and which gets > or < is dependent on how we decide on plotting, not on how we seperate the clusters. Because the values plotted actually correspond to max or min values in that cluster. 
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
figure(145); clf; hold on; set(gcf,'pos', [-513 713 362 271]); % Penalty optimization. 

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

[thissubplot, thisname, thisbool, penBreakBest, datMaxClst, datMinClst] = clusterAtHierarchy(loopOptimizePenalty, 'i', i, j,...
    thissubplot, pltn, pltm, dataSets.data1, ...
    dat, fnew, penaltyFunction, showPenalOptim(1), bools, names); 

if j > 0; % Execute this code if we are going in 2 deep. Combine the name and boolean for our second "layer". e.g. "shallow + seismometer = T240"

    optimPlotStruct = struct('title', cut1, 'xlabel',[cut2 ' split'], ...
        'thisSplit', string(names{1}(i)), 'ind', i); 
    [thissubplot, thisname, thisbool, penBreakBest, datMaxClst, datMinClst] = clusterAtHierarchy(loopOptimizePenalty, 'j', j, k,...
        thissubplot, pltn, pltm, dataSets.data2, ...
        dat, fnew, penaltyFunction, showPenalOptim(2), bools, names, ...
        thisname=thisname, thisbool=thisbool,...
        optimPlotStruct=optimPlotStruct);

    if k > 0; % Execute this code if we are going in 3 deep. 
        [thissubplot, thisname, thisbool, penBreakBest, datMaxClst, datMinClst] = clusterAtHierarchy(loopOptimizePenalty, 'k', k, 0,...
            thissubplot, pltn, pltm, dataSets.data3, ...
            dat, fnew, penaltyFunction, showPenalOptim(3), bools, names, ...
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
    showPlot=false, penalty=penaltyFunction); % Main thing! What is the penalty for this cluster? 
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
            if k == 1; 
                penBreakTemp = round(datMaxClst); 
                penBreakTempk1 = penBreakTemp; % Save this for comparing to during next iteration
            elseif k == 2; 
                penBreakTemp = round(datMinClst); 
% % %                 % Uncomment this if you want to make sure you don't have silly >= and < values that are mismatched by 1
% % %                 if (penBreakTemp < penBreakTempk1) || (penBreakTemp == (penBreakTempk1 + 1)); % We don't want e.g. <= 72 and > 73... that looks suspicious. Neither would we want <= 72 and > 71. 
% % %                     penBreakTemp = penBreakTempk1; 
% % %                 end
            end
            thisText = [thisText sprintf('%1.0f%s', penBreakTemp, unit3) newline]; % Only give new line for third depth if doing optimization. Not categories. Too many categories...
        end
    elseif j > 0; 
        tempNames = names{2}; 
        thisText = tempNames(j); 
        thisText = thisText{1}; 
        if loopOptimizePenalty(2); 
            if j == 1; 
                penBreakTemp = round(datMaxClst); 
                penBreakTempj1 = penBreakTemp; % Save this for comparing to during next iteration
            elseif j == 2; 
                penBreakTemp = round(datMinClst); 
% % %                 % Uncomment this if you want to make sure you don't have silly >= and < values that are mismatched by 1
% % %                 if (penBreakTemp < penBreakTempj1) || (penBreakTemp == (penBreakTempj1 + 1)); % We don't want e.g. <= 72 and > 73... that looks suspicious. Neither would we want <= 72 and > 71.
% % %                     penBreakTemp = penBreakTempj1; 
% % %                 end
            end
            thisText = [thisText ' ' sprintf('%1.0f%s', penBreakTemp, unit2)]; 
        end
        thisText = [thisText newline]; % Always give new line for second depth. 
    else; 
        tempNames = names{1}; 
        thisText = tempNames{i}; 
        thisText = [thisText unit1 newline]; 
    %     thisText = thisText{1}; % Not sure why but I need to comment this
    %     out? 
    end
%     thisText = [thisText unitsAll{}]; 
    thisTextSplitDend = strrep(thisText, newline, ''); % Hopefully use this to indicate where splitting in dendrogram. 
    
    % thisText  = sprintf('%s n=%3.0f, P/n=%2.2f', thisText, numdat, penalty/numdat); 
    thisText = [thisText sprintf(['Pav=%1.1f' newline 'n=%1.0f'], penalty/numdat, numdat)];  % Can't just use sprintf over the whole thing. Else \newline will be erased. How obnoxious. 
    % thistxt = text(x, y, thisname, 'Rotation', 0, 'HorizontalAlignment', 'center'); 
    textPlot = text(x, y, thisText, 'Rotation', 37, ...
        'HorizontalAlignment', 'center', 'fontsize', 16); 
    
    figure(134); % Dendrogram + spectrogram figure
    axes(ax134); 
    [xInset, yInset, widthIns, heightIns] = ijkToAxPos3(i,j,k,splits(1),splits(2),splits(3)); % Get position to plot in dendrogram
    textSpaceDendro = 0.025; 
    yDivDendro = dendroConnectLines(ax134, i, j, k, splits, textSpaceDendro); % connect dendro lines. Find breaking point in lines. 
    thisFontSize = 15; 
    if k > 0; 
        thisFontSize = thisFontSize - 2; 
    end
    text(xInset, yDivDendro+0.0025, thisTextSplitDend, ...
        'verticalalignment', 'bottom',...
        'horizontalalignment', 'center',...
        'fontsize', thisFontSize, ...
        'interpreter', 'tex',...
        'fontname', 'helvetica'); 
 
    
    axIns = axes('Position', [xInset-.5*widthIns, yInset-.5*heightIns, widthIns, heightIns]);
    axes(axIns); 
    if (i == 3) & (j == 0) & (k == 0); 
        addColorbar = true; 
    else; 
        addColorbar = false; 
    end
    [~] = cluster_spread(thiscluster, fnew, replace(thisname, '\newline', '|'), axIns, ...
        showPlot=true, penalty=penaltyFunction, barePlot=true, addColorbar=addColorbar); % Just using this to plot spectra cluster again. 
    axes(axIns); 
    text(0.03, 0.97, sprintf('Pav=%1.1f', penalty/numdat), ...
        'horizontalAlignment', 'left', 'verticalAlignment', 'top',...
        'units', 'normalized'); 
    text(0.97, 0.03, sprintf('n=%1.0f',numdat), ...
        'horizontalAlignment', 'right', 'verticalAlignment', 'bottom',...
        'units', 'normalized')
    grid off; % Turn on only major grid
    axIns.XTickMode = 'manual'; 
    axIns.XTick = [0.001 0.01, 0.1 1]; % Positions of major ticks
    axIns.YMinorTick = 'on';
    set(gca,'Layer','top'); % Axis stuff plots above histogram
%     title(thisTextSplitDend); 
    if (j<1) & (k<1); 
        % Customize first hierarchy level ticks and grid
%         axIns.XTickMode = 'manual'; 
%         axIns.XTick = [0.001 0.01, 0.1 1]; % Positions of major ticks
        axIns.TickLength = 3 .* [0.01, 0.025];    
%         axIns.YMinorTick = 'on';
              
        if i > 1; 
            xticklabels([]); yticklabels([]); 
%             thisMinX = xlim(); 
%             thisMinX = thisMinX(1); 
%             text(thisMinX + diff(xlim()) * .02, ...
%                 mean(ylim()), 'dB'); 
%         else; 
% %             xticklabels([]); %% bb2021.08.30 using normal xtick labels on top left figure. 
%             % ylabel('dB'); 
%             text(-0.05, .5, 'dB', ...
%             'horizontalAlignment', 'center', 'verticalAlignment', 'middle', ...
%             'rotation', 90, 'units', 'normalized')
%             axIns.TickLength = 2.4 .* [0.01, 0.025];    
% 
% %             thisCBar = colorbar('north')
% %             cBarPos = thisCBar.Position; 
% %             cBarPos(1) = cBarPos(1) + 0.3 * cBarPos(3); 
% %             cBarPos(3) = .7 * cBarPos(3); 
% %             set(thisCBar, 'Position', cBarPos); 
% %             colorbar('north'); 
% %             axCBar = axes('Position', [0, 0, .1, .1])
% %             colorbar(axCBar)
        end
        if i == 1; % Add frequency labels, inside plot and not beneath
%             thisMinY = ylim(); %% bb2021.08.30 moving x ticks back
%             outside plot
%             thisMinY = thisMinY(1); 
%             text([0.01, 0.1],...
%                 [thisMinY, thisMinY] + diff(ylim())/20,...
%                 {'0.01 Hz', '0.1 Hz'}, ...
%                 'horizontalAlignment', 'center'); 
            axIns.TickLength = 2 .* [0.01, 0.025];    
            
            %             xticklabels([]); %% bb2021.08.30 using normal xtick labels on top left figure. 
            % ylabel('dB'); 
            text(-0.05, .5, 'dB', ...
            'horizontalAlignment', 'center', 'verticalAlignment', 'middle', ...
            'rotation', 90, 'units', 'normalized')
%             text(0.5, 0.05, 'Hz', ...
%             'horizontalAlignment', 'center', 'verticalAlignment', 'middle', ...
%             'rotation', 0, 'units', 'normalized')
            prevXTicks = get(gca, 'xticklabels'); % Make Hz part of the x tick labels.
            newXTicks = prevXTicks; 
            for iTick = 1:length(prevXTicks); 
                newXTicks{iTick} = [prevXTicks{iTick} ' Hz']; 
            end
            set(gca, 'xticklabels', newXTicks(end:-1:1)); % For some reason when setting the xticks, they apply in reversed order. So flip the newXTicks before settings them. This might not apply on some later version of MATLAB...
            
            axIns.TickLength = 2.4 .* [0.01, 0.025];    

%             thisCBar = colorbar('north')
%             cBarPos = thisCBar.Position; 
%             cBarPos(1) = cBarPos(1) + 0.3 * cBarPos(3); 
%             cBarPos(3) = .7 * cBarPos(3); 
%             set(thisCBar, 'Position', cBarPos); 
%             colorbar('north'); 
%             axCBar = axes('Position', [0, 0, .1, .1])
%             colorbar(axCBar)

        end
    elseif (k<1) & (j>0); 
        % For second hierarchy layer, have to really customize ticks and
        % grid. 
%         grid off; % Turn off whole grid
%         grid on; % Turn on only major grid. 
        axIns.XTickMode = 'manual'; 
        axIns.XTick = [0.001 0.01, 0.1 1]; 
        axIns.TickLength = 3.5 .* [0.01, 0.025]; 
        axIns.YMinorTick = 'on'; 
        xticklabels([]); yticklabels([]); 
    elseif k>0; 
%         grid off; 
        axIns.XTickMode = 'manual'; 
        axIns.XTick = [0.001 0.01, 0.1 1]; 
        axIns.TickLength = 4.5 .* [0.01, 0.025]; 
%         axIns.XMinorTick = 'off'; 
        xticklabels([]); yticklabels([]); 
        
%         xticks([]); yticks([]); 
    end
    %     textPlot = text(gca, 0.025, 0.975, thisText, 'units', 'normalized', 'verticalalignment', 'top'); 
%     thisTitle = title(thisText, 'FontWeight', 'normal'); 
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
if try_boot_penalties; % TODO add an option to or not to do this. It takes a lot of computational time. 
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

    title(sprintf('%s, Datswitch=%1.0f, Component=%1.0f, %s -> %s -> %s', coh_or_spec, datswitch, componentFull, cut1, cut2, cut3) ); 

    ylim([-3.5, 0]); 
    % xlim([-.275, .275]); 
    xlim([-1, 1]); 


    axes(ax134); % Dendrogram + spectrogram figure 
    xTxt = 0.04; 
    pred1 = (1-penaltyTi  /penaltyUnClust)*100; 
    pred2 = (1-penaltyTij /penaltyUnClust)*100; 
    pred3 = (1-penaltyTijk/penaltyUnClust)*100; 
%     predDiff = diff([0, pred1, pred2, pred3]); % Show gain in reduction from previous level
    predDiff = [pred1, pred2, pred3]; % show TOTAL p reduction percent, not change from last time. 
    [~, yTxt, ~, ~] = ijkToAxPos3(1,0,0,splits(1),splits(2),splits(3)); % Get position to plot things on left   
    
    %%% On the dendro/spectrogram figure, insert text stating the thing we
    %%% split, penalty reduction, and penalty total. 
    if false; 
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
    else; % If we don't want to do that, then just say the thing we are splitting
        xTxt = 0.066; 
        text(xTxt, yTxt, ...
            cut1,...
            'HorizontalAlignment', 'center', 'Rotation', 90, 'fontsize', 15); 
        [~, yTxt, ~, ~] = ijkToAxPos3(1,1,0,splits(1),splits(2),splits(3)); 
        text(xTxt, yTxt, ...
            cut2,...
            'HorizontalAlignment', 'center', 'Rotation', 90, 'fontsize', 12.5); 
        [~, yTxt, ~, ~] = ijkToAxPos3(1,1,1,splits(1),splits(2),splits(3)); 
        text(xTxt, yTxt, ...
            cut3,...
            'HorizontalAlignment', 'center', 'Rotation', 90, 'fontsize', 10); 
        scatter([0.0580021482277121, 0.0580021482277121+0.887218045112782],...
                [0.266331658291457, 0.266331658291457+0.585427135678392], 0.00001); % Make tiny dots at borders of figure so exportgraphics won't cut off the edge of some letters. 
%         clipAnt = annotation(figure(134),'rectangle',...
%             [0.0580021482277121 0.266331658291457 0.807218045112782 0.585427135678392],...
%             'LineWidth', 0.000001, 'color', [1,1,1]); % The text keeps getting slightly lopped off after exporting to a pdf. Adding a white, super tiny line around the figure prevents the text from getting lopped off. You can't see the line. It might cause a glitch someday on somebodies computer though. 
    end
        
    
    uistack(ax134, 'bottom');

    % Save all the figs. 
    textFig = sprintf('%s_Datswitch%1.0f_Comp%1.0f-%s-%s-%s', coh_or_spec, datswitch, componentFull, cut1, cut2, cut3);  
    exportgraphics(figure(12), sprintf('Figures/dendrogram__%s.pdf', textFig)); 
    exportgraphics(figure(132),sprintf('Figures/manual_sep/combined__%s.pdf', textFig));
    exportgraphics(figure(134), sprintf('Figures/dendrogram_spec__%s.pdf', textFig),...
        'contentType', 'vector'); 
    exportgraphics(figure(145), sprintf('Figures/optim_combined_%s.pdf', textFig)); 

end 

end
