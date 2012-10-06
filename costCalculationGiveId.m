% function cost = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct,  data1)
function  [bestDepth, mapDistribution] = costCalculationGiveId(meshX, meshY, depthData,...
    image1_struct, otherImage_struct, data1, mapDistribution1, mapDistribution2, gaussianTable)

numOfSample = 1;
% allCost = zeros(1,3);   % cost for 3 different depth. Only the id with best depth are used for distribution update

if( size(image1_struct.imageData,3) == 1)
    isUseColor = false;
else
    isUseColor = true;
end
% draw id from random distribution. The current distribution and the left distribution
 
idSelected1 = drawSample(mapDistribution1, numOfSample);
idSelected2 = drawSample(mapDistribution2, numOfSample);
idSelected = unique([idSelected1(:); idSelected2(:)]);

numOfId = numel(idSelected);
allCost = zeros(numOfId, 3);

for j = 1:3
    for i = 1:numOfId
        data2 = fetchColor( meshX, meshY, depthData(:,j) ,image1_struct, otherImage_struct(idSelected(i)) );
        allCost(i, j) = computeZNCC(data1, data2, isUseColor);
    end
end

% if any(allCost(:) <= -0.95)
%    allCost % allCost reach to very high value
% end
allProb = lookUpGaussiangTable( 1 - allCost, gaussianTable);

% 
% -------------------------------------------------------------------------
% find best depth
cost = zeros(2, 1); maxIdx = zeros(2, 1);
[~,IA,~] = intersect(idSelected, idSelected1);
[cost(1), maxIdx(1)] = max(mean(allCost(IA,:)));    
[~,IA,~] = intersect(idSelected, idSelected2);
[cost(2), maxIdx(2)] = max(mean(allCost(IA,:)));

[~, maxCostIdx ] = max(cost);
switch( maxIdx(maxCostIdx))
    case 1
        bestDepth = depthData(1,1);
    case 2
        bestDepth = depthData(1,2);
    case 3
        bestDepth = depthData(1,3);
end

% update the distribution
% allProb = max(allProb,[], 2); % same id, different depth, this would contribute 
allProb = allProb(:, maxIdx(maxCostIdx));


% update distribution for current distribution.
mapDistribution = mapDistribution2;
for i = 1:numOfId
    priorNotOccluded = mapDistribution( idSelected(i) );
    priorOccluded = 1 - priorNotOccluded;
    observeNotOccluded = allProb(i);
    observeOccluded = 1/400;
    
    mapDistribution(idSelected(i)) = priorNotOccluded * observeNotOccluded;
    mapDistribution(idSelected(i)) = mapDistribution(idSelected(i))/ (mapDistribution(idSelected(i)) + priorOccluded * observeOccluded );
end


