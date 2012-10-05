function idSelected =  drawSample(mapDistribution, K)
%  K is the number of samples

% normalize first:
mapDistribution = mapDistribution./ sum(mapDistribution);

% 
numOfPoluplation = numel( mapDistribution);

idSelected = randsample( 1:numOfPoluplation, K, true, mapDistribution);

idSelected = unique(idSelected);








