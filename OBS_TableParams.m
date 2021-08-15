% OBS_TableParams

figoutpath = 'FIGURES/OBS_Noise_Good/';
if ~exist(figoutpath)
    mkdir(figoutpath);
end

exp_name = {'AACSE','LAU','PAPUA','ALBACORE','SEGMENT','MOANA','PLUME','ENAM',...
    'NOMELT','SCOOBA','GREECE','SHATSKY','MARIANA','HOBITSS','CHILE',...
    'BLANCO','TAIGER','CASCADIA_INITIATIVE','GORDA','NOOTKA','ALST','CASCADIA_KECK',...
    'GLIMPSE','MARIANA_O','YOUNG_ORCA'};
exp_abbr = {'Aa','La','Pa','Al','Se','Ma','Pl','En',...
    'Nm','Sc','Gr','Sh','Ms','Ho','Ch',...
    'Bl','Ta','Ci','Go','No','A','Ck',...
    'Gl','Mo','Yo'};

%%%% indir = '~/Dropbox/DATA_OBS_NOISE_4Paper/';
specdir = 'AVG_STA_GOOD';
TFdir = 'TRANSFUN_GOOD';

%%%% extable = '~/Dropbox/PAPERS/2021/OBSIP_TiltCmp_Review/OBS_Working4Paper.xlsx';
% mattable = '~/Dropbox/PAPERS/2021/OBSIP_TiltCmp_Review/OBS_Working4Paper.mat';
mattable = 'OBS_Working4Paper.mat'; 

flo_vec = 1./[500 10 30 500 30];
fhi_vec = 1./[1 1 10 30 1];

flo_vec = 1./[500];
fhi_vec = 1./[1];

% % % % load('bamako.mat');
% % % % cdepth = flipud(bamako);
% % % % load('lajolla.mat');
% % % % cnoise = (lajolla);
% % % % load('hawaii.mat');
% % % % cclust = (hawaii);
% % % % load('roma.mat');
% % % % cdiff = (roma);
cdepth = winter; 
cnoise = winter; 
cclust = winter; 
cdiff = winter; 

% Colors for station types
scg(1,:) = [166,206,227]; %SIO AB
scg(2,:) = [255,127,0]; % WHOI ARRA
scg(7,:) = [178,223,138]; % WHOI KECK
scg(4,:) = [202,178,214]; % LDEO APG
scg(5,:) = [106,61,154]; % LDEO DPG
scg(3,:) = [227,26,28]; % SIO BB
scg(8,:) = [31,120,180]; %TRM
scg(6,:) = [51,160,44]; % WHOI BB
scg= scg./255;

% symbols for seismometer types
seissym{1} = 'o'; % guralp
seissym{2} = 'x'; % 240
seissym{3} = '^'; % compact


% orig_metadata = '~/Dropbox/METADATA/OBS_Noise_2020/OBSIP_StationData_AGU2020_cleaned.mat';
% good_metadata = '~/Dropbox/METADATA/OBS_Noise_2020/OBSIP_StationData_2021_cleaned.mat';