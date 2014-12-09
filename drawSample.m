function idSelected =  drawSample(mapDistribution, K)
%  K is the number of samples

% normalize first:
% mapDistribution = mapDistribution./ sum(mapDistribution);

% mapDistribution should already normalized before using it.

% 
numOfPoluplation = numel( mapDistribution);
mapDistribution = mapDistribution(:)/sum(mapDistribution(:));
idSelected = randsample( 1:numOfPoluplation, K, true, mapDistribution);

% idSelected = unique(idSelected);    % need apply this to prevent from duplicated calculation








