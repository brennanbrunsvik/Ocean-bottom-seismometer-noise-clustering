
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

showSpectrograms = false; 
penaltyFunction = 'euclidean'; 

% cut1 = 1000; 
% cut2 = 'Guralp CMG3T 120'; 
% cut3 = 'North Pacific'; 
cut1 = 2000; 
cut2 = 'Trillium 240'; 
cut3 = 'North Pacific'; 

shallow =  ( OthVarMat(1,:) < cut1 )'; 
seismom = ( string(cats(8).data) ==  cut2)'; 
environment = ( string(cats(10).data) == cut3)'; 



bools = {{shallow, ~shallow}, {seismom, ~seismom}, {environment, ~environment}}; 
boolsMult = {}; 
names = {{'Shallow', 'Deep'},{[cut2], ['NOT ' cut2]},{[cut3], ['NOT ' cut3]}}; 
splits = [2, 2, 2]; 

penalties = {}; 



dat = spc_stack_filt; 

% cluster_spread(dat (bools{1}{1},:), fnew, names{1}{1})
% cluster_spread(dat (bools{1}{2},:), fnew, names{1}{2})
% cluster_spread(dat (and(bools{1}{1},bools{2}{1}),:) )

% for ilevel = [1:2];%length(bools)]; 
%     for isplit = 1:splits[ilevel]; 
%         thisbool = ones(size(bools{ilevel}{isplit})); 
% %         thisname = names{ilevel}{isplit}; 
%         thisname = ''; 
%         for ilevelagain = [ilevel:-1:1]; % Construct the name and boolean for this cluster level, and an individual option for this cluster level
%             thisbool = thisbool .* bools{ilevelagain}{isplit}; 
%             thisname = [names{ilevelagain}{isplit} '-' thisname]; 
%         end
% %         thisbool = logical(thisbool); 
% %         penalty = cluster_spread(dat(thisbool, :), fnew, thisname); 
% %         penalties{ilevel}{isplit} = penalty; 
%         disp(thisname)
%     end
% end


%% Automated algorithm to create a dendrogram type thingy of our clusters. 
% penaltiesAll = {}; % Store all penalties

% First get whole dataset
penalty = cluster_spread(dat, fnew, 'All data', showPlot=true, penalty=penaltyFunction)

penaltiesi   = {}; 
penaltiesij  = {}; 
penaltiesijk = {}; 
penalties = {}; % Penalties. How to access? penalties{1}{i}; penalties{2}{i,j}; penalties{3}{i,j,k}; 

figure(1); clf; hold on; set(gcf, 'pos', [1921 1648 1505 349]); 

for i = [1:splits(1)]; % First level
for j = [0:splits(2)]; % Second level
for k = [0:splits(3)]; % Third level
    
% level = 0; % Maybe can use this sometime? 
% if i > 0; 
%     level = level + 1;
%     if j > 0; 
%         level = level + 1; 
%         if k > 0; 
%             level = level + 1; 
%         end
%     end
% end

if (j<1) & (k>0); continue; end % Doesn't make any sense to split the third layer and not the second. Algorithm breaks without this
     
thisname = names{1}{i}; % Base level name. e.g. "shallow" or "deep"
thisbool = bools{1}{i}; % Base level boolean. The dataset corresponding to thisname. 

if j > 0; % Execute this code if we are going in 2 deep. Combine the name and boolean for our second "layer". e.g. "shallow + seismometer = T240"
    thisname = [thisname '\newline' names{2}{j}]; 
    thisbool = and(thisbool, bools{2}{j}); 
    if k > 0; % Execute this code if we are going in 3 deep. 
        thisname = [thisname '\newline' names{3}{k}]; 
        thisbool = and(thisbool, bools{3}{k}); 
    end
end

% disp(sprintf('%s %1.0f %1.0f %1.0f', thisname, i, j, k) ) % What thing did we just analyze, and what were the indecies? 
thiscluster = dat(thisbool, :); % Select the cluster
penalty = cluster_spread(thiscluster, fnew, replace(thisname, '\newline', '|'), ...
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
    x = x + (j-1.5) * .5; 
    if k > 0; 
        x = x + (k-1.5) * .25; 
    end
end

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

% Plot the penalties. 
axis off; 
xtxt = get(gca, 'xlim'); 
xtxt = xtxt(1); 
% scatter(xtxt, -1); 
text(xtxt, -1, sprintf('Tot P=%6.0f', penaltyTi  ), 'HorizontalAlignment', 'right'); 
text(xtxt, -2, sprintf('Tot P=%6.0f', penaltyTij ), 'HorizontalAlignment', 'right'); 
text(xtxt, -3, sprintf('Tot P=%6.0f', penaltyTijk), 'HorizontalAlignment', 'right'); 

title([num2str(cut1) ' ' cut2 ' ' cut3 ] ); 

exportgraphics(gcf, 'FIGURES/dendrogram.pdf'); 







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




