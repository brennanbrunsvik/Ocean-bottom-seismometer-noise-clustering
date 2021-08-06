%% Setting up the data:
clear
close all
% Load the data:
getdr=pwd;
load([getdr,'/','SpecIn_NoCorr.mat'])
spc_stack=squeeze(spc_stack(:,:,1));

% Finding the bad stations:
bind=find(isnan(sum(spc_stack))==1);
spc_stack(:,bind)=[];
spc_stack=spc_stack';

% Reading in the SOM:
addpath([getdr,'/somtoolbox'])

%% Running the SOM algorithm:

% SOM parameters:
SomVals=spc_stack;
numval=15;
N=numval;
a=5;
b=3;
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
        subplot(1,N,kk)
        semilogx(fc,SomVals(indin(jj),:),'r-','LineWidth',1)
        hold on
    end
end
        
% Plotting the nodes:
figure(1)
for kk=1:N
    subplot(1,N,kk)
    semilogx(fc,Maps(kk,:),'k-','LineWidth',3)
    axis([1/1000 1 -200 -50]) 
end