function dp = neurometric_dprime(data,targetTrials,dim)
% dp = neurometric_dprime(data,targetTrials,[dim])
% 
% Computes a neurometric d' comparing data samples where targetTrials is true
% vs where it is false.
% 
% Inputs:
%   data    ...     
% 
% formula:  dp = 2.*(mT - mF) ./ (sT + sF);
%   where 'T' are the samples identified in targetTrials, and 'F' are the
%   samples not identified in targetTrials. 'm' is the mean, 's' is the
%   standard deviation of 'T' or 'F'

narginchk(2,3);

if nargin < 3 || isempty(dim), dim = 1; end


assert(iequal(size(data),size(targetTrials)),'epa:metric:neurometric_dprime:UnequalSizes', ...
    'size(data) must be the same as size(targetTrials)')

indT = targetTrials;
indF = ~targetTrials;

mT = mean(data(indT),dim);
mF = mean(data(indF),dim);

sT = std(data(indT),0,dim);
sF = std(data(indF),0,dim);

dp = 2.*(mT - mF) ./ (sT + sF);