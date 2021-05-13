function [c,b,uv] = psth(obj,varargin)
% [c,b,uv] = obj.psth(par)
% 
% par is a structure:
%   
% Output:
%  c    ... histogram counts
%  b    ... histogram bins
%  v    ... values associated with histogram

par.eventvalue = 'all';
par.binsize    = 0.01;
par.window     = [0 1];

par = epa.helper.parse_parameters(par,varargin);

[t,~,v] = obj.eventlocked(par);

uv = unique(v);

if length(par.window) == 1, par.window = sort([0 par.window]); end

b = par.window(1):par.binsize:par.window(2);
c = nan(length(uv), length(b)-1);
for i = 1:length(uv)
    ind = uv(i) == v;
    c(i,:) = histcounts(t(ind),b);
end

