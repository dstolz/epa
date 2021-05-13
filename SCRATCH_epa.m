%% EPA

% root directory
% pth = 'C:\Users\Daniel\Documents\ExampleCarasPhysData\210424_concat';
pth = 'C:\Users\Daniel\Documents\ExampleCarasPhysData\SUBJ-ID-228-210227';


% load config file contains acquisition parameters
ffn = fullfile(pth,'config.mat');
load(ffn) 


% determine spike breakpoints (in samples) from csv file
d = dir(fullfile(pth,'*concat_breakpoints.csv'));
ffn = fullfile(d.folder,d.name);
fid = fopen(ffn,'r');
bp = textscan(fid,'%s %d','delimiter',',','HeaderLines',1);
fclose(fid);
BPfileroot = cellfun(@(a) a(1:find(a=='_')-1),bp{1},'uni',0);
BPsamples  = bp{2};
BPtimes = double(BPsamples) ./ ops.fs;
BPtimes = [0; BPtimes]; % makes indexing spikes later easier

% load spike clusters with spike times (in secconds) from txt files
d = dir(fullfile(pth,'*concat_cluster*.txt'));
ffn = cellfun(@fullfile,{d.folder},{d.name},'uni',0);
ST  = cellfun(@dlmread,ffn,'uni',0);



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
    end
end

disp([S.Name])

%% Read Events from CSV files with event information


d = dir(fullfile(pth,'CSV files','*trialInfo.csv'));

onsetEvent = 'Trial_onset';
offsetEvent = 'Trial_offset';



for i = 1:length(S)
    
    c = contains(string({d.name}),S(i).Name);
    
    if ~any(c), continue; end
    
    fprintf('Reading Events from file for "%s" ...',S(i).Name);
    
    fid = fopen(fullfile(d(i).folder,d(i).name),'r');
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

addpath('c:\users\Daniel\src\epsych_v1.1\TDTfun\')


tankPath = 'C:\Users\Daniel\Documents\ExampleCarasPhysData\SUBJ-ID-228-210227\FreqTuning-210307-114557';
tankd = dir(fullfile(tankPath,'*.Tbk'));

[~,tankName,~] = fileparts(tankd.name);

% Tank block name(s) should be the same as one or more of the Sessions ???
blockName = 'FreqTuning-210307-114557'; 

warning('off','MATLAB:ui:actxcontrol:FunctionToBeRemoved');
tankData = TDT2mat(fullfile(tankPath,tankName),blockName,'TYPE',2,'VERBOSE',false);
warning('on','MATLAB:ui:actxcontrol:FunctionToBeRemoved');

% ind = [S.Name] == string(blockName);
ind = 4;

fprintf('Reading Events from TDT Tank for "%s" ...',S(ind).Name)
eventInfo = tankData.epocs;
eventNames = fieldnames(eventInfo);
for i = 1:length(eventNames)
    e = eventInfo.(eventNames{i});
    onoffs = [e.onset e.offset];
    S(ind).add_Event(eventNames{i}, onoffs, e.data);
end
fprintf(' done\n')



%% Example 1a - Using 'Name,Value' paired input
S(2).Clusters(3).plot_raster('event',"AMdepth");


%% Example 1b - Using parameter structure for input

C = S(2).Clusters; % Copy handles to the Cluster objects

par = [];
par.event = "AMdepth";
par.window = [-0.2 1];
par.showlegend = false;

tiledlayout(1,numel(C))
for i = 1:length(C)
    nexttile
    C(i).plot_raster(par)
end

%% Example 1c
C = S(2).Clusters(3);

figure
par = [];
par.event = "AMdepth";
par.eventvalue = 0.5;
par.window = [-0.2 1];

C.plot_psth(par);


%%

idx = 4;
for cidx = 1:length(S(idx).Clusters)
    
    C = S(idx).Clusters(cidx);
        
    RF = epa.ReceptiveField(C,[S(idx).Events(2) S(idx).Events(1)]);
    
    RF.metric = 'mean';
    RF.plotstyle = 'imagesc';
    RF.plot;
    set(gca,'xscale','log')
    pause
end




