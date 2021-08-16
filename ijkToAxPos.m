function [xCent,yCent] = ijkToAxPos(i,j,k, maxi, maxj, maxk); 
%%% This section just for visualizing. 
y = 0; x = 0; 
if i > 0; y = y - 1; end 
if j > 0; y = y - 1; end 
if k > 0; y = y - 1; end

posibX = linspace(-.5, .5, maxi); 
x = posibX(i); 
if j >= 1; 
%     posibX = linspace(-1, 1, splits(2))/(splits(2)+1)/splits(1); 
    posibX = linspace(-.5, .5, maxj)/(maxi) .* .8; 
    x = x + posibX(j); 
end
if k >= 1; 
%     posibX = linspace(-1, 1, splits(3))/(splits(3)+1)/splits(2)/splits(1); 
%     posibX = linspace(-2, 2, splits(3))/(splits(3)+2)/splits(2)/splits(1); % Don't fully understand why [-2, 2] works...
    posibX = linspace(-.5, .5, maxk)/maxj/maxi .* 1; % Don't fully understand why [-2, 2] works...
    x = x + posibX(k); 
end

xCent = x; 
yCent = y; 

end