% Need to run Manual_clustering.m first. Untill I convert to a function. 
function dist = cluster_spread(clst, fnew, thistitle, thisax, options); 
    arguments
        clst
        fnew
        thistitle
        thisax
        options.showPlot = false
        options.penalty = 'euclidean'
        options.ampLim = 1; % 1 for OBS data. 2 for coherance. 
        options.barePlot = false; 
        options.addColorbar = false; 
    end
% if length(varargin) > 0; 
%     showPlot = varargin{1}; 
% else; 
%     showPlot = true; 
% end

if strcmp(options.penalty, 'euclidean'); 
    % clst = spc_stack_filt; 
    meanSpec = mean(clst); % Mean point in M dimensional space where M is the number of frequencies. 
    deMeaned = clst - meanSpec; % Note for later: could remove the main eigenvector of this cluster... but then each cluster has a different spread metric. Not sure if that's good or bad.
    dists = sqrt(sum(deMeaned.^2, 2)); % L2 norm, of distance from mean spectrum

    dist = sum(dists); % One way of quantifying spread. 
elseif strcmp(options.penalty, 'spectral_angle'); 
    N = size(clst,1);  %Number of stations
    
%     if N == 1; 
%         disp('Oh no! 1 station in cluster'); 
%     end
    
    eachDot = zeros(N, N ); 
    eachNorm = zeros(N, 1); 
    for ispec = [1:N]; % First dimension of clst corresponds to each datum
        % One dot product: clst(ispec,:)*clst(ispec,:)'
        thisClst = clst(ispec,:); 
        dotProds = thisClst*clst(:,:)'; % Dot product between ispec spectra and each other spectra. 
        thisNorm = norm(thisClst); % I verified that sqrt(thisClst * thisClst') = norm(thisClst); 
        eachDot(ispec,:) = dotProds;
        eachNorm(ispec) = thisNorm; 
    end
    eachNorm = eachNorm * eachNorm' ; % Now we have |Ai|*|Aj| at eachNorm(i,j), which = eachNorm(j,i). 
    dotOverNorm = eachDot./eachNorm; 
    dotOverNorm(dotOverNorm>1) = 1; % Numerical Instabilities. 
    theta = acosd(dotOverNorm); 
%     thetarad = deg2rad(theta); 
%     figure(2); clf; hold on; pcolor(eachNorm); colorbar(); title('Each Norm'); 
%     figure(3); clf; hold on; pcolor(eachDot ); colorbar(); title('Each Dot'); 
%     figure(4); clf; hold on; pcolor(eachDot./eachNorm); colorbar(); title('Dot/Norm'); 
%     figure(5); clf; hold on; pcolor(theta); colorbar(); title('Spectral Angles'); 
    
    dists = zeros(N, 1); 
    n = N-1; % Number of stations that one can be compared to. Simply ignore the 0 angle, which comes from comparing a spectra with itself. 
    for ispec = [1:N]; 
        meanAngle = sqrt(sum((theta(ispec,:).^2))/n); % RMS. Note the special use of n % TODO can do a better mean angle. 
        dists(ispec) = meanAngle; % dists isn't the best name here. This is instead a penalty. 
    end
    dist = sum(dists); 
    
    meanSpec = mean(clst); % I don't know how to calculate mean spectrum with angle... just use normal mean for now. 
        
    % Now have dot products and norms. 
    
end

if N <= 1; 
    dist = NaN; 
end

% need to have dist and meanSpec come out of penalty function. 

% TODO I don't think RMS is good. I should somehow normalize to account for
% the fact that if we have half the points and have clustered neutrally
% well, then the expected spread is halved. Or maybe that's not right. 

if options.showPlot; 
axes(thisax); 

% figure(132); subplot(5, 3, 
% if size(clst) > 0; 
semilogx(fnew, meanSpec, 'k'); % Actually just plotting thise here to set x log. 
hold on; 

% vmin = min(dists); vmax = max(dists); 
vmin = 2; vmax = 7; % Manually setting colors. Should make a function argument. 
cm = colormap(parula(10));

if length(dists) > 2; 
    colors = colour_get(dists, vmax, vmin, cm); 
elseif length(dists) <= 2; 
    colors =  ones(size(dists)) * [1 0 0] ; % All red, since I don't know what to do here yet. 
end

% if options.ampLim == 1; 
if max(max(clst)) < -30; % Probably db scale
xlim([min(fnew), max(fnew)]); 
ylim([-200, -50]); 
if ~ options.barePlot; xlabel('Frequency (Hz)'); ylabel('dB'); end
else
if ~ options.barePlot; xlabel('Frequency (Hz)'); ylabel('Coherance?'); end
end

% semilogx(fnew, clst'); 
% %     semilogx(fnew,Maps(kk,:),'k-','LineWidth',3)
% % axis([flo fhi -200 -50]) 
% xlim([flo, fhi]); ylim([-200, -50]); 
for ispec = [1:length(dists)];
    thing = semilogx(fnew', clst(ispec, :), 'Color',colors(ispec, :));
end

semilogx(fnew, meanSpec, 'k', 'linewidth', 3); % Actually just plotting thise here to set x log. 
grid on ;
if ~ options.barePlot; 
%     cbar = colorbar(); 
    options.addColorbar = true; 
    box on; 
    grid on ;
    title([thistitle sprintf(' - P: %5.1f. P/n: %3.1f', dist, dist / size(dists,1))] ); 
% else;
% %     disp('Do some stuff'); 
%     xticks([]); 
%     yticks([])
end

if options.addColorbar; 
    thisCBar = colorbar('EastOutside'); 
%     set(thisCBar, 'Label', 'Penalty (\circ)'); 
    ylabel(thisCBar, 'Penalty', 'fontsize', 12); 
%     thisCBar=colorbar;
    thisCBar.Position(1) = thisCBar.Position(1) + 0.0425; 
    thisCBar.Position(3) = thisCBar.Position(3) * .7; 
    thisCBar.Ticks = [2:10]; 
    caxis([vmin, vmax]); 
%     thisCBar.Position = thisCBar.Position + 1e-10; % 1e-10;
%     cBarPos = thisCBar.Position; 
%     cBarPos(1) = cBarPos(1) + 0.3 * cBarPos(3); 
%     cBarPos(3) = .7 * cBarPos(3); 
%     set(thisCBar, 'Position', cBarPos);
    
    newTickLabels = thisCBar.TickLabels; 
    for ilabel = [1:length(newTickLabels)]; 
            newTickLabels{ilabel} = [newTickLabels{ilabel} '\circ']; 
    end
    thisCBar.TickLabels = newTickLabels; 
end

% dist = RMSdist; 
% end

%%%%% exportgraphics(gcf,['Figures/manual_sep/' thistitle '.png']); 
% figure(2); clf; 
% semilogx(fnew, deMeaned');
% hold on; 
% 
% cm = colormap(parula(300)); 
end

end