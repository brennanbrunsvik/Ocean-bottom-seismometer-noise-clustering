% Figure out which stations are good for every analysis, rather than just
% for vertical, or horizontal, etc. 

OBS_TableParams;

sameStasAllAnalyses = false; 


datswitch = 1; % Look in prep data
component = 1; % Look in prep data
prep_data; 
netsta = string(netvec) + '.' + string(stnmvec); % This should be the same from each dataset

goodDat = logical(ones(1,size(netsta,2))); 
% Get stations where all corrected verticals, and horizontal and pressure,
% is all good. 
datswitch = 1; component = 1; prep_data; goodDat(bind) = false; 
datswitch = 2; component = 1; prep_data; goodDat(bind) = false; % TODO Already down to 404, the minimum number of stations? 
datswitch = 3; component = 1; prep_data; goodDat(bind) = false; 

datswitch = 1; component = 2; prep_data; goodDat(bind) = false; 
datswitch = 1; component = 3; prep_data; goodDat(bind) = false; 
datswitch = 1; component = 4; prep_data; goodDat(bind) = false; 

goodDatAllSpec = find(goodDat); 

% Now find where all coh is also good
datswitch = 1; component = 1; prep_data_coh; goodDat(bind) = false; 
datswitch = 1; component = 2; prep_data_coh; goodDat(bind) = false; 
datswitch = 1; component = 3; prep_data_coh; goodDat(bind) = false; 
datswitch = 2; component = 1; prep_data_coh; goodDat(bind) = false; 

goodDatAll = find( goodDat); 
badDatAll  = find(~goodDat); 
goodNetSta = netsta(goodDatAll); 

% sum( )% 405 are good. I wonder if Helen removed the bad
% vertical from the new dataset, which makes it at 404 is good.

% Now see how this stacks up against the info Helen had in the Mat table. 
load(mattable); 
mtGoodDat = logical( OBS_table.ZIsGood .* OBS_table.H1IsGood .* OBS_table.H2IsGood .* OBS_table.PIsGood ); 
mtNetSta = string(OBS_table.Network) + '.' + string(OBS_table.Station); 
goodMtNetSta = mtNetSta(mtGoodDat)'; 

[goodMtNetSta;     [" " goodNetSta] ]'; % By looking at this, 7D.FN09C was good in the mattable, but not good in the new data Helen sent. This station probably was removed due to having a mislabeled vertical channel. 

save('stations_good_all_analyses.mat', 'goodDatAll', 'badDatAll'); 

% The end result is that "goodDatAll" has the stations which were good for
% every single analysis. But I should double check with Helen. Seems like a
% lot of stations... 404. 

% goodNetSta is correct. goodMtNetSta has an extra bad station. 