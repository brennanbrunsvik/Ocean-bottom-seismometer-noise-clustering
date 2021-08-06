%% Setting up the data:
clear
close all

OBS_TableParams;

datswitch = 1;
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

component = 1;
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
bind=find(isnan(sum(spc_stack))==1);
gind=find(isnan(sum(spc_stack))==0);
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
% SOM parameters:
SomVals=spc_stack_filt;
sD=som_data_struct(SomVals);
SM=som_make(sD,'init','lininit','algorithim','batch','munits',N,'msize',[a b],'lattice','rect','shape','sheet','neigh','gaussian');

% Finding to which som each map belongs, this is the minimum euclidean distance:
DistVals=nan(N,size(SomVals,1));
for i=1:N;
    for j=1:size(SomVals,1);
        DistVals(i,j)=sqrt(sum((SM.codebook(i,:)-SomVals(j,:)).^2));
    end
end
[~,ind]=min(DistVals,[],1);

% Calculating the number assigned to each:
NumVals=nan(N,1);
for i=1:N;
    NumVals(i,1)=length(find(ind==i));
end

% Saving out the maps:
Maps=SM.codebook;

% Adding the individual assignment on there:
figure(1)
for kk=1:N
    indin=find(ind==kk);
    for jj=1:length(indin)
        subplot(a,b,kk)
        semilogx(fnew,SomVals(indin(jj),:),'-','LineWidth',1,'Color',clusclr(kk,:))
        hold on
    end
end
        
% Plotting the nodes:
figure(1); clf
for kk=1:N
    subplot(a,b,kk)
    semilogx(fnew,Maps(kk,:),'k-','LineWidth',3)
    axis([flo fhi -200 -50]) 
    if kk~= 1 & kk ~= 4 & kk ~= 7 & kk ~= 10
            set(gca,'ytick',[])
        end
    if kk<10
        set(gca,'xtick',[])
    end
    if kk>=10
        xlabel('Frequency (Hz)')
    end
    if kk== 1 | kk == 4 | kk == 7 | kk == 10
            ylabel('dB')
    end
    set(gca,'FontSize',8)
end
    
        set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperUnits','inches');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPosition',[.05 .05 8 10]);
    filename=sprintf('%s/%d_%ds/%s_%s_Cluster.pdf',figoutpath,(1/flo),(1/fhi),figlabel,compsuf);
print(gcf,'-dpdf',filename)

figure(100); clf; 
for kk=1:N
    semilogx(fnew,Maps(kk,:),'-','LineWidth',3,'Color',clusclr(kk,:))
    hold on
    xlim([flo fhi])
%     axis([flo fhi -200 -50]) 
        xlabel('Frequency (Hz)')
            ylabel('dB')
    set(gca,'FontSize',8)
    text(fnew(1),Maps(kk,end),sprintf('%d',kk),'Color',clusclr(kk,:),'FontSize',12)
end
axis tight
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperUnits','inches');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPosition',[.05 .05 5 5]);
    filename=sprintf('%s/%d_%ds/%s_%s_ClusterNodes.pdf',figoutpath,(1/flo),(1/fhi),figlabel,compsuf);
print(gcf,'-dpdf',filename)

% Making plots of the other variables:
% 1 - water depth; 2 - dist to plate boundary; 3 - distance to coastline; 
% 4 - crustal age; 5 - sediment thickness; 6 - surface current;
% 7 - station type; 8 - seismometer type; 9 - pressure type;
% 10 - environment; 11 - experiment

figlab = {'Depth','PltBnd','CoastDist','CrustAge','SedThk','SrfCurr','StaType','SeismType','PresType','WatEnv','Exp'};

% numeric, continuous, no nan
OthVarMat=nan(6,size(SomVals,1));
OthVarMat(1,:)=elev_vec(gind);
suff{1} = 'Water Depth (m)';
OthVarMat(2,:)=pltbnd(gind);
suff{2} = 'Plate Bndy Dist (km)';
OthVarMat(3,:)=lndvec(gind);
suff{3} = 'Coastline Dist (km)';

sedvec(find(isnan(sedvec))) = -2000;
crsage(find(isnan(crsage))) = -50;
srfcur(find(isnan(srfcur))) = -0.5;

OthVarMat(4,:)=crsage(gind);
suff{4} = 'Crustal Age (Myr)';
OthVarMat(5,:)=sedvec(gind);
suff{5} = 'Sediment Thickness (m)';
OthVarMat(6,:)=srfcur(gind);
suff{6} = 'Surface Current (m/s)';

for kk=1:6
        data = OthVarMat(kk,:);
        [N2,C2] = histcounts((data));
    figure(kk+1)
    for jj=1:numval
        subplot(a,b,jj)
        indin=find(ind==jj);
        [N1,C1] = histcounts(data(indin),C2);
        percN = N1./N2;
        clear Clabel
        for kj = 1:length(C2)-1
            Clabel(kj) = C2(kj);
        end
        bar(Clabel,percN,'FaceColor',clusclr(jj,:),'EdgeColor',clusclr(jj,:));
        box on
        ylim([0 1])
        if jj~= 1 & jj ~= 4 & jj ~= 7 & jj ~= 10
            set(gca,'ytick',[])
        end
        set(gca,'FontSize',8)
        if jj== 1 | jj == 4 | jj == 7 | jj == 10
            ylabel('Number of Stations');
    end
if jj >=10
    xlabel(suff(kk))
end
    end
     set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperUnits','inches');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPosition',[.05 .05 8 10]);
filename=sprintf('%s/%d_%ds/%s_%s_Cluster_%s.pdf',figoutpath,(1/flo),(1/fhi),figlabel,compsuf,char(figlab(kk)));
print(gcf,'-dpdf',filename)
end



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

for kk=7:11
        data = cats(kk).data;
        [N2,C2] = histcounts(categorical(data));
    figure(kk+1)
    for jj=1:numval
        subplot(a,b,jj)
        indin=find(ind==jj);
        [N1,C1] = histcounts(categorical(data(indin)));
        clear percN
        for ic = 1:length(C2)
            idx = find(strcmp(C2(ic),C1));
            if ~isempty(idx)
            percN(ic) = N1(idx)/N2(ic);
            else
                percN(ic) = 0;
            end
        end
        bar(categorical(C2),percN,'FaceColor',clusclr(jj,:),'EdgeColor',clusclr(jj,:));
        box on
        ylim([0 1])
        if jj~= 1 & jj ~= 4 & jj ~= 7 & jj ~= 10
            set(gca,'ytick',[])
        end
        set(gca,'FontSize',8)
        if jj== 1 | jj == 4 | jj == 7 | jj == 10
            ylabel('Number of Stations');
    end
if jj >=10
    xlabel(suff(kk))
end
    end
    set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperUnits','inches');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPosition',[.05 .05 8 10]);
filename=sprintf('%s/%d_%ds/%s_%s_Cluster_%s.pdf',figoutpath,(1/flo),(1/fhi),figlabel,compsuf,char(figlab(kk)));
print(gcf,'-dpdf',filename)
end


end
        
    

