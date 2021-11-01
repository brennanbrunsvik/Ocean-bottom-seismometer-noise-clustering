
%% Setting up the data:
% clear
% close all


% datswitch = 1;
if datswitch == 1
    datfile = 'SpecIn_NoCorr.mat';
    figlabel = 'Spectra_NoCorr';
elseif datswitch ==2
    datfile = 'SpecIn_AllCorr.mat';
    figlabel = 'Spectra_AllCorr';
elseif datswitch ==3
    datfile = 'SpecIn_TiltCorr.mat';
    figlabel = 'Spectra_TiltCorr';
end

% component = 2;
if component ==1
    compsuf = 'Z';
elseif component == 2
    compsuf = 'H1';
elseif component == 3
    compsuf = 'H2';
end

% Load the data:
getdr=pwd;
load([getdr,'/',datfile;])
spc_stack=squeeze(spc_stack(:,:,component)); % vertical only right now

% Finding the bad stations:
% Finding the bad stations:
if sameStasAllAnalyses; 
    load('stations_good_all_analyses.mat'); % generated using /Users/brennanbrunsvik/Documents/UCSB/ORCA/Noise_clustering/Manual_clustering/findGoodStas.m
    bind = badDatAll; 
    gind = goodDatAll; 
else; 
    bind=find(isnan(sum(spc_stack))==1); % bb2021.11.01 Should be spc_stack OR coh_stack depending on datswitch??? I switched from coh_stack to spc_stack
    gind=find(isnan(sum(spc_stack))==0);
end
spc_stack(:,bind)=[];
spc_stack=spc_stack';

% figure out path
figoutpath = 'FIGURES/OBS_Noise_Good/Clusters/';
if ~exist(figoutpath)
    mkdir(figoutpath);
end

% Reading in the SOM:
addpath([getdr,'/somtoolbox'])

%% Running the SOM algorithm:

numval=12;
N=numval;
a=4;
b=3;

clrdiv = round(length(cclust)/N);
clusclr = interp1([1:length(cclust)],cclust,[1:clrdiv:length(cclust)]);

% set up filter loop
for ifilt = 1:length(flo_vec)
    close all
    flo = flo_vec(ifilt);
    fhi = fhi_vec(ifilt);
    idxf = find(fc<=fhi & fc>=flo);
    fnew = fc(idxf)';
    spc_stack_filt = spc_stack(:,idxf,:);
if ~exist(sprintf('%s/%d_%ds/',figoutpath,(1/flo),(1/fhi)))
    mkdir(sprintf('%s/%d_%ds/',figoutpath,(1/flo),(1/fhi)));
end


end

dat = spc_stack_filt; 
    

% % SOM parameters:
SomVals=spc_stack_filt;
% numeric, continuous, no nan
OthVarMat=nan(6,size(SomVals,1));
OthVarMat(1,:)=elev_vec(gind);
suff{1} = 'Water Depth (m)'; % No nan values
OthVarMat(2,:)=pltbnd(gind);
suff{2} = 'Plate Bndy Dist (km)'; % No nan values
OthVarMat(3,:)=lndvec(gind);
suff{3} = 'Coastline Dist (km)'; % No nan values

% sedvec(find(isnan(sedvec))) = -2000;
% crsage(find(isnan(crsage))) = -50;
% srfcur(find(isnan(srfcur))) = -0.5;

OthVarMat(4,:)=crsage(gind);
suff{4} = 'Crustal Age (Myr)';
OthVarMat(5,:)=sedvec(gind);
suff{5} = 'Sediment Thickness (m)';
OthVarMat(6,:)=srfcur(gind);
suff{6} = 'Surface Current (m/s)';

% categorical

cats(7).data = stavec(gind);
suff{7} = 'OBS Design';
cats(8).data = smtvec(gind);
suff{8} = 'Seismometer';
cats(9).data = prsvec(gind);
suff{9} = 'Pressure Gauge';
cats(10).data = envvec(gind);
suff{10} = 'Environment';
cats(11).data = expvec(gind);
suff{11} = 'Experiment';

% component = 2; datswitch=1; prep_data; figure(1); clf; hold on; plot(dat')