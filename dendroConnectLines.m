function [yDiv] = dendroConnectLines(ax, i, j, k, splits, textSpace); 
% figure(134); 
% i = 2; j = 2; k = 1; 
% splits = [3, 2, 3]; 
% axes(ax134); 
axes(ax); 
lineWidth = 1.5; 
lineCol= 'k'; 
% textSpace = 0.038 * .8 ; % Needs to be same as ijkToAxPos3.m TODO make input variable
% labelSpaceTop = 0;%textSpace+.01; % Needs to be same as ijkToAxPos3.m TODO make input variable
divShiftUp = 0.006; % How far show dividing dendrogram points be above subplot
% textSpace = 0.04; 

[xInset, yInset, widthIns, heightIns] = ...
    ijkToAxPos3(i,j,k,splits(1),splits(2),splits(3)); % Get position to plot in dendrogram 

iprev = i; 
jprev = j; 
kprev = k; 
if k > 0; 
    kprev = 0; 
elseif jprev > 0; 
    jprev = 0; 
end

[xPrev, yPrev, widthPrev, heightPrev] = ...
    ijkToAxPos3(iprev,jprev,kprev,splits(1),splits(2),splits(3)); % Get position to plot in dendrogram

if (j<1) & (k<1); 
    yDiv = yPrev + heightIns/2 + 0.006; % Manually add a little space if there was no dendro break above. This is just for putting text there. 
%     yDiv = yInset + heightIns/2 + 0.006; % Manually add a little space if there was no dendro break above. This is just for putting text there. 
else; 
%     if (j>0)&(k==0); 
%         yDiv = yPrev - heightPrev/2 - textSpace; 
%     elseif (j>0)&(k>0); 
%         yDiv = yPrev - heightPrev/2 - textSpace - labelSpaceTop; 
        yDiv = yInset + heightIns/2 + divShiftUp; 
%     end
    plot([xInset, xInset], [yInset, yDiv], ...
        'linewidth', lineWidth, 'color', lineCol); 
    plot([xInset, xPrev], [yDiv, yDiv] , ...
        'linewidth', lineWidth, 'color', lineCol); 
    plot([xPrev, xPrev], [yPrev, yDiv], ...
        'linewidth', lineWidth, 'color', lineCol); 
end





% plot([xInset, xPrev], [yInset, yPrev], ...
%     'linewidth', 1, 'color', [166, 113, 38]./255); 
end