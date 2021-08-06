% FIGURE_noiseclust
% FIGURE_NoisePeaks
% script to find a plot locations and magnitudes of high noise peaks on
% spectra

clear; close all
getdr=pwd;

% Helen add the path and files for this locally, it really bloated the
% folder storage size...
OBS_TableParams;
% run('/Users/coats/Desktop/For_Helen/NOISE_OBS_2020/OBS_TableParams');

flo = 1/1000;
fhi = 2.5;

load(mattable);
OBS_table_orig = OBS_table;

TF_label_list = {'Z2-1'}; % check coherence after removing tilt and removing compliance

stations = OBS_table.Station;
networks = OBS_table.Network;
expfldr = OBS_table.ExperimentFolder;
expabrv = OBS_table.ExperimentAbbreviation;
% isgood = OBS_table.IsGood;
Zisgood = OBS_table.ZIsGood;
H1isgood = OBS_table.H1IsGood;
H2isgood = OBS_table.H2IsGood;
Pisgood = OBS_table.PIsGood;

% parameters to keep track of for cluster analysis
waterdepth = OBS_table.WaterDepth;
sedthk = OBS_table.SedimentThickness;
statype = OBS_table.InstrumentDesign;
seismometer = OBS_table.Seismometer;
prestypes = OBS_table.PressureGauge;
landdistC = OBS_table.DistanceToLandCoarse;
experiments = OBS_table.Experiment;
platbond = OBS_table.DistanceToPlateBoundary;
crustage = OBS_table.AgeOceanicCrust;
envir = OBS_table.Environment;
surfcurr = OBS_table.SurfaceCurrent;

experiments_all = unique(expfldr);
pressure_all = unique(prestypes);
statypes = unique(statype);
seistypes = unique(seismometer);

ocav = 8;

ie = 1;

ii = 1;
Ts = 1/fhi;
while Ts<1/flo
Tl = Ts*2;
Tc(ii) = sqrt(Ts*Tl);
Ts=Ts*2^(1/ocav);
ii = ii+1;
end

fc = 1./Tc;
for iexp = 1:length(experiments_all)
    exp = char(experiments_all(iexp));
    inpath_dir = sprintf('%s%s/%s',indir,exp,TFdir);
    idx = strcmp(exp,expfldr);
    idxsta = find(idx==1);
    for id = 1:length(idxsta)
        ista = idxsta(id);
        sta = char(stations(ista));
        net = char(networks(ista));
        station_file = sprintf('%s/%s%s/%s%s_AVERAGE_transfun.mat',inpath_dir,net,sta,net,sta);
        if exist(station_file,'file') == 0
            continue
        end
        load(station_file);
        
        f = transprop.params.f;
        clear Tcsta
        ii = 1;
        Tssta = 1/max(f);
        while Tssta<1/f(2)
            Tl = Tssta*2;
            Tcsta(ii) = sqrt(Tssta*Tl);
            Tssta=Tssta*2^(1/ocav);
            ii = ii+1;
        end
        fc_sta =1./Tcsta;
        PI = 4*atan(1);
        w = 2*PI*transprop.params.f;
        wc = 2*PI*fc_sta;
        
        for it = 1:length(TF_label_list)
            
            TF_label = char(TF_label_list(it));
            for ic = 1:length(corr)
                if strcmp(corr(ic).label,TF_label)==1;
                    idxx(it) = ic;
                    break
                end
            end
        end
        
        
        for it =1:length(TF_label_list)
            isbad=0;
        if Zisgood(ista) ~=1
            coh_stack(:,ie,1) = NaN(size(fc)); %ZP coh - tilt
            isbad=1;
        end
        
        % indcies are hardwired do not edit
        % ZP coh - tilt
        
        if it ==1
            cohpz = corr(idxx(it)).cohere;
            cohpzsmooth = smoothSpectrum_octave(cohpz,f',fc_sta,ocav);
            coh_stack(:,ie,1) = interp1(fc_sta,cohpzsmooth,fc);
            if H1isgood(ista) ~=1
                coh_stack(:,ie,1) = NaN(size(fc));
            end
            if H2isgood(ista) ~=1
                coh_stack(:,ie,1) = NaN(size(fc));
            end
            if Pisgood(ista) ~=1
                coh_stack(:,ie,1) = NaN(size(fc));
            end
        end
        end
        
        elev_vec(ie) = waterdepth(ista);
        stavec(ie) = statype(ista);        
        smtvec(ie) = seismometer(ista);
        sedvec(ie) = sedthk(ista);
        lndvec(ie) = landdistC(ista);
        expvec(ie) = expabrv(ista);
        crsage(ie) = crustage(ista);
        srfcur(ie) = surfcurr(ista);
        pltbnd(ie) = platbond(ista);
        prsvec(ie) = prestypes(ista);
        envvec(ie) = envir(ista);
        ie = ie+1;
    end
    
end

% Saving the data to input into the clustering algorithm
save Coh_TiltCorr coh_stack expvec lndvec sedvec smtvec stavec elev_vec fc crsage srfcur pltbnd prsvec envvec