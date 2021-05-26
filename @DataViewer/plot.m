function plot(obj,src,event)

S = obj.curSession;
C = obj.curClusters;

E1 = obj.curEvent1;
E2 = obj.curEvent2;

f = figure('NumberTitle','off');
f.Color = 'w';

ps = obj.curPlotStyle;
ps = ['epa.plot.' ps];

tmpObj = feval(ps,obj.curClusters(1));

par = obj.Par;

switch tmpObj.DataFormat
    case '1D'
        par.event = E1.Name;
        par.eventvalue = obj.handles.SelectEvent1Values.Value;
    case '2D'
        par.eventX = E1.Name;
        par.eventXvalue = obj.handles.SelectEvent1Values.Value;
        par.eventY = E2.Name;
        par.eventYvalue = obj.handles.SelectEvent2Values.Value;
    otherwise
        error('Unrecognized plot DataFormat, ''%s''',tmpObj.DataFormat)
end


par.parent = f;

m = length(S);
n = length(C);

t = tiledlayout(m,n);

for s = 1:length(S)
    for c = 1:length(C)
        
        ax = nexttile(t);
        par.ax = ax;
        
        if isfield(par,'showlegend')
            par.showlegend = false;
        end
        
        SC = S(s).find_Cluster(C(c).Name);
        
        pObj = feval(ps,SC,par);
        pObj.plot;
        
        set(par.ax,'UserData',pObj);
        
        if c == 1
            ax.YAxis.Label.String = {S(s).Name,ax.YAxis.Label.String};
        end
        
        if s == 1
            ax.Title.String = SC.Name;
        else
            ax.Title.String = "";
        end
    end
end


