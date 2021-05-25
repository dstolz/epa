function plot(obj,src,event)
S = obj.curSession;
C = obj.curClusters;
E = obj.curEvent1;

f = figure('NumberTitle','off');
f.Color = 'w';

ps = obj.curPlotStyle;
ps = ['epa.plot.' ps];

par = obj.Par;
par.event = E.Name;
par.eventvalue = obj.handles.SelectEvent1Values.Value;

par.parent = f;

m = length(S);
n = length(C);

t = tiledlayout(m,n);

for s = 1:length(S)
    for c = 1:length(C)
        
        ax = nexttile(t);
        par.ax = ax;
        par.showlegend = false;
        
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


