function [residRemove] = predictor_importance_r2(predictors, dat) 
% residRemove is actually R2 (or something very similar)
% of the regression error when the corresponding data type is REMOVED. 
% So the most important data should correspond to the lowest R2 when that
% data is removed. 
% Brennan, 2021.08.03
% Predictor needs to be transposed outside this function maybe

residRemove = nan( size(predictors, 2), 1); 

for idat = [1:size(predictors, 2)]; 
    keep = ones(size(predictors, 2), 1);
    keep(idat) = 0; 
    keep = logical(keep); 
    predictorsSub = predictors(:, keep); 
    predictorsSub = [ones(size(predictorsSub,1), 1), predictorsSub]; % Need a column of ones in predicors. For intercept I think. https://www.mathworks.com/matlabcentral/answers/67399-mvregress-does-not-do-multivariate-linear-regression
    [beta, sigma, resid] = mvregress(predictorsSub, dat);
%     resid2 = rms(resid, 'all')^2; 
    
    % Calculate R^2. Do at each frequency individually. Then take mean r^2
    % over all frequencies. 
    dforward = dat - resid; % Easiest way to get forward model. dtrue-dest=resid, so dest = dtrue-resid
    dmean = mean(dat); 
    R2 = mean(1 - sum( (resid).^2)./sum( (dat-mean(dat) ).^2) )

    residRemove(idat) = R2; 
    
    % Example of predicted versus actual data...
    figure(10); clf; hold on; 
    for ifreq = [1:size(dat, 2)]; 
        scatter(dat(:,ifreq), dat(:,ifreq) - resid(:,ifreq), '.'); 
        xlim([-200, -50]); ylim([-200, -50]); 
        xlabel('db (data)'); 
        ylabel('db (estimated)'); 
    end
end


end