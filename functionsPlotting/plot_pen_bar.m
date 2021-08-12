% bb2021.08.12 Make some bar plot to consolidate all the final penalty
% information. 

labelsAll = {'Water Depth'; 'Plate Bndy Dist'; 'Coastline Dist'; ...
            'Crustal Age'; 'Sediment Thickn'; 'Surface Current';...
            'OBS Design'; 'Seismometer'; 'Pressure Guage'; 'Environment'; 'Experiment'}; 
        
        
coh_or_spec = 'spec'; 
datswitch = 1; 
component = 1; 

finPenFile = sprintf('pen_results/penalties_%s_datswitch%1.0f_component%1.0f_3layer.mat',...
    coh_or_spec, datswitch, component); % variable "eachPenalty"
% eachPenalty = finalPenalty; % Delete this. 

load(finPenFile); 


allBar = [eachPenalty, eachPenalty+1, eachPenalty, ...
    eachPenalty, eachPenalty, eachPenalty, eachPenalty]


% Can plot histogram of final penalty, based on each third hierarchy depth
figure(70); clf; set(gcf, 'pos', [-746 247 394 771]); hold on; 
barh(allBar); 

barSmall = barh(allBar-50, 'linewidth', 1.); 

minx = min(min(allBar))-100; 
maxx = max(max(allBar))+50; 
xlim([minx, maxx]); 

set(gca, 'yticklabel', labelsAll)
for itxt = [1:length(labelsAll)]; 
    textH = text(minx-20, itxt, [labelsAll{itxt} '   '] ,...
        'Rotation', 90); %'HorizontalAlignment', 'right'); 
end



xlabel('Penalty using this variable as third hierarchy depth'); 
set(gca, 'ytick', []); 

box on; 
grid on; 

