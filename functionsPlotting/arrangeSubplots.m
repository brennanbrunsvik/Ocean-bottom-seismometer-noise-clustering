function [pos, posLeft, widthIns, widthTot] = arrangeSubplots(maxi); 

buffPer = 0.03; % How much buffer to put on both left and right of each subplot. As a ratio out of 1. 
widthIns = -1 / (maxi * (-1 - 2 * buffPer)); 
buffWidth = buffPer * widthIns; 
dPos = repmat([buffWidth, widthIns, buffWidth]', maxi, 1); 
pos = cumsum([0; dPos]); 
posLeft = pos(1:3:end-2); 
pos = (pos(2:end) + pos(1:end-1))/2;
pos = pos(2:3:end); 

widthTot = widthIns + 2 * buffWidth; 

end