% figure(134); 
% i = 2; j = 2; k = 1; 
% splits = [3, 2, 3]; 
axes(ax134); 

[xInset, yInset, widthIns, heightIns] = ...
    ijkToAxPos2(i,j,k,splits(1),splits(2),splits(3)); % Get position to plot in dendrogra

iprev = i; 
jprev = j; 
kprev = k; 
if k > 0; 
    kprev = 0; 
elseif jprev > 0; 
    jprev = 0; 
end

[xPrev, yPrev, widthPrev, heightPrev] = ...
    ijkToAxPos2(iprev,jprev,kprev,splits(1),splits(2),splits(3)); % Get position to plot in dendrogram

plot([xInset, xPrev], [yInset, yPrev], '-k', 'linewidth', 1); 
