% Plot penalty grid searches as a function of water depth for each seismic
% component. 
% The .mat files used here are produced in "optimize_penalty.m". 

% clear;
set(groot, 'defaultAxesFontName', 'helvetica'); 

% Load data
datZ  = load('grid_search_comp_ 1_datType_1_data.mat'); % vertical component
datZc = load('grid_search_comp_ 1_datType_2_data.mat'); % corrected vertical component
datH  = load('grid_search_comp_23_datType_1_data.mat'); % Horizontal component

% Unpack structures. 
datZ = datZ .plotDat; 
datZc= datZc.plotDat; 
datH = datH .plotDat; 

% Set legend labels. 
datZ .label = 'Z'; 
datZc.label = 'Z corr'; 
datH .label = 'H'; 

% Start plot
figure(146); clf; hold on; 
set(gcf, 'pos', [382 598 323 244]); 
box on; 
grid on; 
ylim([4, 5]); 

% Define parameters
LineWidth = 1; 
plot(datZ .breaks, datZ .penalty, 'LineWidth', LineWidth,...
    'DisplayName', datZ .label); 
plot(datZc.breaks, datZc.penalty, 'LineWidth', LineWidth,...
    'DisplayName', datZc .label);  
plot(datH .breaks, datH .penalty, 'LineWidth', LineWidth,...
    'DisplayName', datH .label);  

leg = legend(); 
leg.Location = 'best'; 
xlabel('Depth Split (m)'); 
ylabel('Penalty (\circ)'); 

exportgraphics(gcf, 'grid_search_each_component_combined.pdf'); 



%% What happens when we look at second derivative of smoothed penalty grid searches? 
% Filter data, so we can calculate derivatives and see if we get anything
% useful. 
w = gausswin(30);
w = w / sum(w); 
datZ .penFilt = filter(w, 1, datZ .penalty); 
datZc.penFilt = filter(w, 1, datZc.penalty); 
datH .penFilt = filter(w, 1, datH .penalty); 

% Plot filtered data. 
figure(148); clf; hold on; 
plot(datZ. penFilt); 
plot(datZc.penFilt); 
plot(datH .penFilt); 

ddZ  = diff(diff(  datZ .penFilt  )); 
ddZc = diff(diff(  datZc.penFilt  )); 
ddH  = diff(diff(  datH .penFilt  )); 
ddX  = datZ .breaks(2:end-1); 


% Plot derivatives. 
figure(147); clf; hold on; 
box on; grid on; 
plot(ddX, ddZ, 'LineWidth', LineWidth,...
    'DisplayName', datZ .label); 
plot(ddX, ddZc, 'LineWidth', LineWidth,...
    'DisplayName', datZc.label); 
plot(ddX, ddH, 'LineWidth', LineWidth,...
    'DisplayName', datH .label); 
legend()
xlabel('Depth'); 
ylabel('Second derivative of smoothed penalty'); 

exportgraphics(gcf, 'grid_search_DERIVATIVES.pdf'); 
