%% EPA

% Specify the root directory to a data set
DataPath = 'C:\Users\Daniel\Documents\ExampleCarasPhysData\SUBJ-ID-228\210227_concat_organized\';

% load config file contains acquisition parameters
load(fullfile(DataPath,'config.mat'))


% determine spike breakpoints (in samples) from csv file
d = dir(fullfile(DataPath,'*concat_breakpoints.csv'));
ffn = fullfile(d.folder,d.name);
fid = fopen(ffn,'r');
bp = textscan(fid,'%s %d','delimiter',',','HeaderLines',1);
fclose(fid);
BPfileroot = cellfun(@(a) a(1:find(a=='_')-1),bp{1},'uni',0);
BPsamples  = bp{2};
BPtimes = double(BPsamples) ./ ops.fs;
BPtimes = [0; BPtimes]; % makes indexing spikes later easier

% load spike clusters with spike times (in secconds) from txt files
d = dir(fullfile(DataPath,'*concat_cluster*.txt'));
ffn = cellfun(@fullfile,{d.folder},{d.name},'uni',0);
ST  = cellfun(@dlmread,ffn,'uni',0);

clusterAlias = cellfun(@(a) a(find(a == '_',1,'last')+1:find(a=='.',1,'last')-1),ffn,'uni',0);

% Create a Session object for each recording block,
% split up spiketimes into sessions based on breakpoints
clear S
for i = 1:length(BPfileroot)
    S(i) = epa.Session(ops.fs);
    S(i).Name = BPfileroot{i};
    for j = 1:length(ST)
        ind = ST{j} > BPtimes(i) & ST{j} <= BPtimes(i+1);
        xx = ST{j}(ind) - BPtimes(i); % recording block starts at 0 seconds
        S(i).add_Cluster(j,xx);
        S(i).Clusters(end).Name = clusterAlias{j};
    end
end

disp([S.Name])

%% Read Events from CSV files with event information


d = dir(fullfile(DataPath,'*trialInfo.csv'));

onsetEvent  = 'Trial_onset';
offsetEvent = 'Trial_offset';



for i = 1:length(S)
    c = contains(string({d.name}),S(i).Name);
    
    if ~any(c), continue; end
    
    
    fprintf('Reading Events from file for "%s" ...',S(i).Name);
    
    fid = fopen(fullfile(d(c).folder,d(c).name),'r');
    dat = {};
    while ~feof(fid), dat{end+1} = fgetl(fid); end
    fclose(fid);
    
    c = cellfun(@epa.helper.tokenize,dat,'uni',0);
    dat = cellfun(@matlab.lang.makeValidName,c{1},'uni',0);
    c(1) = [];
    v = cellfun(@str2double,c,'uni',0);
    v = cat(2,v{:})';
    
    
    % Event timings for these files are the same for all events
    ind = ismember(dat,onsetEvent);
    evOns = v(:,ind);
    dat(ind) = []; v(:,ind) = [];
    
    ind = ismember(dat,offsetEvent);
    evOffs = v(:,ind);
    dat(ind) = []; v(:,ind) = [];
    
    % Add each field as an Event
    for j = 1:length(dat)
        S(i).add_Event(dat{j},[evOns evOffs],v(:,j));
    end
    
    fprintf(' done\n')
end


%% Read Events from TDT Tank
% TODO: Move necesary TDT files to +epa??
addpath('c:\users\Daniel\src\epsych_v1.1\TDTfun\')

d = dir(fullfile(DataPath,'*.Tbk'));

for t = 1:length(d)
    tank = fullfile(d(t).folder,d(t).name);
    
    [~,tankName,~] = fileparts(tank);
    
    tankFFN = fullfile(d(t).folder,d(t).name);
    
    % Tank block name(s) should be the same as one or more of the Sessions ???    
    warning('off','MATLAB:ui:actxcontrol:FunctionToBeRemoved');
    
    blockName = TDT2mat(tankFFN);
    blockName = blockName{1};
    
    tankData = TDT2mat(tankFFN,blockName,'TYPE',2,'VERBOSE',false);
    warning('on','MATLAB:ui:actxcontrol:FunctionToBeRemoved');
    
    ind = [S.Name] == string(blockName);
    
    fprintf('Reading Events from TDT Tank for "%s" ...',S(ind).Name)
    eventInfo = tankData.epocs;
    eventNames = fieldnames(eventInfo);
    for i = 1:length(eventNames)
        e = eventInfo.(eventNames{i});
        onoffs = [e.onset e.offset];
        S(ind).add_Event(eventNames{i}, onoffs, e.data);
    end
    fprintf(' done\n')
    
    
end






%% List Session names
disp([S.Name]')



%% Save one or more Session objects to load later


save('TEST_SESSIONS.mat','S')


%% Load saved Session objects

load('TEST_SESSIONS.mat')


%% Example 1a - Using 'Name,Value' paired input
S(2).Clusters(3).plot_raster('event',"AMdepth");


%% Example 1b - Using parameter structure for input

par = [];
par.event = "AMdepth";
par.eventvalue = 0.5;
par.window = [-0.2 1];
par.showlegend = false;


% Plot all clusters at once by not specifying a specific index
S(2).Clusters.plot_raster(par); 

    
    
%% Example 1c

figure
par = [];
par.event = "AMdepth";
par.eventvalue = 0.5;
par.window = [-0.2 1];
par.binsize = 0.01;
par.normalization = 'firingrate';

% we can use S.find_Session to return a Session based on a substring
Spost = S.find_Session("Post"); % find the "Passive-Post-210227-125506" session

Spost.Clusters.plot_psth(par);





%% Plot a summary of all Clusters in Session 3

% we can use S.find_Session to return a Session based on a substring
Spost = S.find_Session("Post"); % find the "Passive-Post-210227-125506" session

par = [];
par.event = "AMdepth";
par.eventvalue = 0.5;
par.window = [-.5 1];
par.normalization = 'probability';
par.parent = gcf;
par.parent.Color = 'w';
par = Spost.Clusters.plot_summary(par);

figure(gcf);




%%

Stuning = S.find_Session("Tuning");

xEvent = Stuning.find_Event("Freq");
yEvent = Stuning.find_Event("Levl");

tiledlayout(1,length(Stuning.Clusters));
for cidx = 1:length(Stuning.Clusters)
    
    C = Stuning.Clusters(cidx);
    
    nexttile
    
    
    RF = epa.ReceptiveField(C,[xEvent yEvent]);
    RF.window = [0 0.1];
    RF.metric = 'mean';
    RF.plotstyle = 'imagesc';
    RF.smoothmethod = 'interpft';
    RF.plot;
    set(gca,'xscale','log')
end
sgtitle(Stuning.Name)

%%

