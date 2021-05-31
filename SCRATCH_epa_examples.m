%% Create a new Session object(s)

DataPath = 'C:\Users\Daniel\Documents\ExampleCarasPhysData\SUBJ-ID-228\210227_concat_organized\';
% DataPath = 'C:\Users\Daniel\Documents\ExampleCarasPhysData\SUBJ-ID-219\210129_concat';
TDTTankPath = DataPath;
S = epa.kilosort2session(DataPath,TDTTankPath);

%% DataBrowser GUI

D = epa.DataBrowser;

%% Access currently selected data in the DataBrowser

C = D.curClusters;

E1 = D.curEvent1;
E2 = D.curEvent2;

E1vals = D.curEvent1Values;
E2vals = D.curEvent2Values;

curSession = D.curSession;





%% we can use S.find_Session to return a Session based on a substring
Spost = S.find_Session("Post"); % find the "Passive-Post-210227-125506" session

disp(Spost)

%% Example 1a - Using 'Name,Value' paired input

h = epa.plot.PSTH_Raster(Spost.Clusters(3),'event',"AMdepth");

% you can also set properties after creating the plot object
h.eventvalue = 0.5;

h.plot;

%% Update existing plot
h.eventvalue = 0.35;



%% Stop listening to changes
h.listenForChanges = false;


%




