function [xCent,yCent, widthIns, heightIns] = ijkToAxPos3(i,j,k, maxi, maxj, maxk); 
%%% This section just for visualizing. 
% y = 0; x = 0; 
% widthIns = 1/(maxi*maxj) ; 
% heightIns = 1/4 ; 
% titleSpace = .15; 
% if i > 0; 
%     y = y - 1; 
% end 
% if j > 0; 
%     widthIns = widthIns * .5; 
%     heightIns = heightIns * .5; 
%     y = y - .8 - titleSpace; % 1; 
% end 
% if k > 0; 
%     widthIns = widthIns * .6; %TODO not sure if .6 is a good value here. 
%     heightIns = heightIns * .6;
%     y = y - .8/2 - titleSpace; % 1; 
% end
% 
% posibX = linspace(-.5, .5, maxi); 
% x = posibX(i); 
% if j >= 1; 
% %     posibX = linspace(-1, 1, splits(2))/(splits(2)+1)/splits(1); 
%     posibX = linspace(-.5, .5, maxj)/(maxi) .* .8; 
%     x = x + posibX(j); 
% end
% if k >= 1; 
% %     posibX = linspace(-1, 1, splits(3))/(splits(3)+1)/splits(2)/splits(1); 
% %     posibX = linspace(-2, 2, splits(3))/(splits(3)+2)/splits(2)/splits(1); % Don't fully understand why [-2, 2] works...
% %     posibX = linspace(-.5, .5, maxk)/maxj/maxi .* 1; % 
% %     posibX = linspace(-.5, .5, 2)/(maxi) .* .8 * .45; 
%     posibX = [-.5, .5] ./ maxi .* .8 .* .5; 
%     posibX = [ posibX, posibX, posibX, posibX, posibX, posibX, posibX, posibX, posibX]; 
%     x = x + posibX(k); 
%     
%     y = y - floor( (k-1) / 2)*heightIns*4; % How much we need to shift y down to keep this in correct collumn 
% %     mod(k,2); % Put in either left or right side. 
% %     mod(k, maxk)
% end
% 
% xCent = x / 2 +.5; 
% yCent = y / 4 + 1; 

% Create positions that are equally spaced with a buffer on both sides of
% each axis inset. Spreads from 0 to 1. 

textSpace = 0.05; 

[posi, posiLeft, widthi, widthiTot] = arrangeSubplots(maxi); 
[posj, posjLeft, widthj, widthjTot] = arrangeSubplots(maxj); 
[posk, posKLeft, widthk, widthkTot] = arrangeSubplots(maxk); 

posF = posi(i); 
posLeftF = posiLeft(i); 
widthF = widthi; 
posY = 0.9 - .5 * widthF; 

if j > 0; 
    posY = posY - .5 * widthF; 
    posF = posj(j) .* widthiTot + posLeftF;
    posLeftF = posjLeft(j) .* widthiTot + posLeftF; 
    widthF = widthj .* widthiTot; 
    posY = posY - .5 * widthF - textSpace; 
end
if k > 0; 
    posY = posY - .5 * widthF; 
    posF = posk(k) .* widthiTot .* widthjTot + posLeftF; 
    widthF = widthk .* widthiTot .* widthjTot; 
    posY = posY - .5 * widthF - textSpace; 
end 

yCent = posY; 
% yCent = .8; 
% if j > 0; 
%     yCent = yCent - .25; 
% end 
% if k > 0; 
%     yCent = yCent -.25; 
% end
xCent = posF; 
widthIns = widthF; 
heightIns = widthIns; 


end