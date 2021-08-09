% clear; 
% close all; 

showSpectrograms = false; 
showPenalOptim = false; 
penaltyFunction = 'spectral_angle'; 
levels_break = 2; 
coh_or_spec = 'spec'; % coherance (coh) or spectra (spec)

OBS_TableParams;
datswitch = 1; % Look in prep data
component = 1; % Look in prep data

if strcmp(coh_or_spec, 'coh'); 
    prep_data_coh; 
else
    prep_data; 
end

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


labelsNums = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current'}; 
finalPenalty = zeros(size(labelsNums,1), 1); 
for iquant = [2, 3, 4, 5, 6]; 


cut1 = 'Instrument'; 
cut2 = 'Water'; 
cut3 = labelsNums{iquant}; 

dataSets = struct('data1', string(cats(8).data), ...
                  'data2', OthVarMat(1,:), ...
                  'data3', OthVarMat(iquant, :)); 

% shallow =  ( OthVarMat(1,:) < cut1 )'; 
% seismom = ( string(cats(8).data) ==  cut2)';
% seismom(:) = nan; % Don't want seismom anymore. 
environment = ( string(cats(10).data) == cut3)'; 



bools = {... % Data 1
           {(string(cats(8).data)=="Trillium 240")', ...
            (string(cats(8).data)=="Guralp CMG3T 120")', ...
            (string(cats(8).data)=="Trillium Compact")'}, ...    
        ... % Data 2
            { OthVarMat(1,:)' < 220, ...
              and(OthVarMat(1,:)' >=220, OthVarMat(1,:)' <4160),...
              OthVarMat(1,:)' >=4160}, ...
        ... % Data 3
           { 'Nope', "Still nope"}}; 
boolsMult = {}; 
names = {
    {'Trillium 240', 'Guralp CMG3T 120', 'Trillium Compact'},... % Names 1
    {'Shallow', 'Deep'},... % Names 2
    {[cut3], ['NOT ' cut3]}... % Names 3
    }; 
splits = [3, 2, 2];

loopOptimizePenalty = [ false true true ] ; 

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

figure(12); clf; hold on; set(gcf, 'pos', [1921 1648 1505 349]); % Dendrogram figure
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

[thissubplot, thisname, thisbool] = clusterAtHierarchy(loopOptimizePenalty, 'i', i, j,...
    thissubplot, pltn, pltm, dataSets.data1, ...
    dat, fnew, penaltyFunction, showPenalOptim, bools, names); 

if j > 0; % Execute this code if we are going in 2 deep. Combine the name and boolean for our second "layer". e.g. "shallow + seismometer = T240"

    [thissubplot, thisname, thisbool] = clusterAtHierarchy(loopOptimizePenalty, 'j', j, k,...
        thissubplot, pltn, pltm, dataSets.data2, ...
        dat, fnew, penaltyFunction, showPenalOptim, bools, names, ...
        thisname=thisname, thisbool=thisbool);

    if k > 0; % Execute this code if we are going in 3 deep. 
        [thissubplot, thisname, thisbool] = clusterAtHierarchy(loopOptimizePenalty, 'k', k, 0,...
            thissubplot, pltn, pltm, dataSets.data3, ...
            dat, fnew, penaltyFunction, showPenalOptim, bools, names, ...
            thisname=thisname, thisbool=thisbool);

%         thisname = [thisname '\newline' names{3}{k}]; 
%         thisbool = and(thisbool, bools{3}{k}); 
    end
end

% disp(sprintf('%s %1.0f %1.0f %1.0f', thisname, i, j, k) ) % What thing did we just analyze, and what were the indecies? 
thiscluster = dat(thisbool, :); % Select the cluster



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

x = (i-1.5) * 1; 
if j > 0; 
    x = x + (j-1.5) ./ splits(2); 
    if k > 0; 
        x = x + (k-1.5) ./ splits(3); 
    end
end

figure(12); 
scatter(x, y, 1); 
thistxt = text(x, y, thisname, 'Rotation', 0, 'HorizontalAlignment', 'center'); 
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
    penaltyTi = penaltyTi + penaltiesi{i}; 
end
if (j > 0) & (k < 1); 
    penaltyTij = penaltyTij + penaltiesij{i}{j}; 
end
if k > 0; 
    penaltyTijk = penaltyTijk + penaltiesijk{i}{j}{k}; 
end
end
end
end

figure(12); 
% Plot the penalties. 
axis off; 
xtxt = get(gca, 'xlim'); 
xtxt = xtxt(1); 
% scatter(xtxt, -1); 
text(xtxt, -1, sprintf('Tot P=%6.0f', penaltyTi  ), 'HorizontalAlignment', 'right'); 
text(xtxt, -2, sprintf('Tot P=%6.0f', penaltyTij ), 'HorizontalAlignment', 'right'); 
text(xtxt, -3, sprintf('Tot P=%6.0f', penaltyTijk), 'HorizontalAlignment', 'right'); 

title([num2str(cut1) ' ' cut2 ' ' cut3 ] ); 

exportgraphics(figure(12), sprintf('Figures/dendrogram_%s_datswitch_%1.0f_comp%1.0f.pdf', coh_or_spec, datswitch,component)); 
exportgraphics(figure(132),sprintf('Figures/manual_sep/combined_%s_datswitch_%1.0f_comp%1.0f.png', coh_or_spec, datswitch,component)); 

finalPenalty(iquant) = penaltyTijk; 

end



% % % 
% % % %%% Very manual approach below. 
% % % % Split into shallow and deep
% % % pen = cluster_spread(dat( shallow,:), fnew, 'Z<2000'); 
% % % pen = cluster_spread(dat(~shallow,   :), fnew, 'Z>2000'); 
% % % pen = cluster_spread(dat( :   ,   :), fnew, 'Z all'); 
% % % 
% % % 
% % % % Split into Trillium 240 and not Trillium 240
% % % pen = cluster_spread(dat( seismom,:), fnew, 'Seismom T 240'); 
% % % pen = cluster_spread(dat(~seismom,   :), fnew, 'Seismom ~T240'); 
% % % pen = cluster_spread(dat( :   ,   :), fnew, 'Seismom all'); 
% % % % 'Trillium 240'




