function [xCent,yCent, widthIns, heightIns] = ijkToAxPos3(i,j,k, maxi, maxj, maxk);
% Create positions that are equally spaced with a buffer on both sides of
% each axis inset. Spreads from 0 to 1.

lBord = 0.1;
rBord = 0.9;
% textSpace = 0.038; % Needs to be same as dendroConnectLines.m TODO make input variable
textSpace = 0.039; % Needs to be same as dendroConnectLines.m TODO make input variable
labelSpaceTop = textSpace-0.01; % Needs to be same as dendroConnectLines.m TODO make input variable

[posi, posiLeft, widthi, widthiTot] = arrangeSubplots(maxi);
[posj, posjLeft, widthj, widthjTot] = arrangeSubplots(maxj);
[posk, posKLeft, widthk, widthkTot] = arrangeSubplots(maxk);

posF = posi(i);
posLeftF = posiLeft(i);
widthF = widthi;
posY = 0.9 - .5 * widthF;


if (j>0) | (k>0); 
    posY = posY - labelSpaceTop; % Put some space in there for axis labels. 
end

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

yCent = yCent .* (rBord-lBord) + lBord;
xCent = xCent .* (rBord-lBord) + lBord;
widthIns = widthIns .* (rBord-lBord);
heightIns = heightIns .* (rBord-lBord);


end
