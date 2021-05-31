%% Create a new Session object(s)

DataPath = 'C:\Users\Daniel\Documents\ExampleCarasPhysData\SUBJ-ID-228\210227_concat_organized\';
TDTTankPath = DataPath;
S = epa.kilosort2session(DataPath,TDTTankPath);

%% DataViewer GUI

D = epa.DataViewer;

%%

D.plot

%% Load saved Session objects

% load('TEST_SESSIONS.mat')
load('TEST_SESSIONS_Subject-227.mat')

%% Example 1a - Using 'Name,Value' paired input
S(2).Clusters(3).plot_raster('event',"AMdepth");


%% Example 1b - Using parameter structure for input
clf
par = [];
par.event = "AMdepth";
par.eventvalue = 0.5;
par.window    = [-0.2 1];
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
par.window = [-1 1];
par.normalization = 'probability';
par.parent = gcf;
par.parent.Color = 'w';

par = Spost.Clusters.plot_summary(par);

figure(gcf); % raise the figure to the front




%% Plot receptive fields

Stuning = S.find_Session("Tuning");

xEvent = Stuning.find_Event("Freq");
yEvent = Stuning.find_Event("Levl");


clf

tiledlayout('flow');

for C = [Stuning.Clusters]
    ax = nexttile;
    
    RF = epa.ReceptiveField(C,[xEvent yEvent]);
    RF.ax         = ax;
    RF.window     = [0 0.025];
    RF.metric     = 'mean';
    RF.plotstyle  = 'surf';
    RF.smoothdata = 3;
    RF.plot;
    
    ax.XScale = 'log';
end

sgtitle(Stuning.Name)





