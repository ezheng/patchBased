% function cost = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct,  data1)
function  [bestDepth, mapDistribution] = costCalculationGiveId(meshX, meshY, depthData,...
    image1_struct, otherImage_struct, data1, mapDistribution1, mapDistribution2, gaussianTable, annealing)

% propogate distribution:
% mapDistribution2 = mapDistribution2 * 0.5 + mapDistribution1 * 0.5;
% mapDistribution2 = mapDistribution1;

numOfSample = 5;
% allCost = zeros(1,3);   % cost for 3 different depth. Only the id with best depth are used for distribution update

if( size(image1_struct.imageData,3) == 1)
    isUseColor = false;
else
    isUseColor = true;
end
% draw id from random distribution. The current distribution and the left distribution
 
% idSelected{1} = drawSample( (mapDistribution1 + mapDistribution2)*0.5, numOfSample);
idSelected{1} = drawSample( mapDistribution1, numOfSample);
idSelected{2} = idSelected{1};
% idSelected = unique([idSelected1(:); idSelected2(:)]);
% idSelected{1} = [1 2 3 4]';
% idSelected{2} = [1 2 3 4]';

% numOfId = numel(idSelected);
% if(numOfId == 1)
%     numOfId
% end

allCost = NaN(numel(otherImage_struct), 3);
for j = 1:3
    for i = 1:numel(idSelected)
        for k = 1:numel(idSelected{i})
            if(isnan(allCost(idSelected{i}(k), j)))
                data2 = fetchColor( meshX, meshY, depthData(:,j) ,image1_struct, otherImage_struct(idSelected{i}(k)));
                allCost(idSelected{i}(k), j) = computeZNCC(data1, data2, isUseColor);
            end
        end
    end
end

% if any(allCost(:) <= -0.95)
%    allCost % allCost reach to very high value
% end
% allProb = lookUpGaussiangTable( 1 - allCost, gaussianTable);

% 
% -------------------------------------------------------------------------
% find best depth
cost = zeros(2, 1); maxIdx = zeros(2, 1);
% [~,IA,~] = intersect(idSelected, idSelected1);
[cost(1), maxIdx(1)] = max(mean(allCost(idSelected{1},:),1),[], 2);    
% [~,IA,~] = intersect(idSelected, idSelected2);
[cost(2), maxIdx(2)] = max(mean(allCost(idSelected{2},:),1),[], 2);

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
% allProb = lookUpGaussiangTable( 1 - allCost, gaussianTable);
% allProb = allProb(:, maxIdx(maxCostIdx));

costWithBestDepth = allCost(:, maxIdx(maxCostIdx));
nonTestedId = find(isnan(costWithBestDepth));
for i = 1:numel(nonTestedId)
    idx= nonTestedId(i);
    data2 = fetchColor( meshX, meshY, depthData(:,maxIdx(maxCostIdx)), image1_struct, otherImage_struct(idx));
    costWithBestDepth(idx) = computeZNCC(data1, data2, isUseColor);
end

probWithBestDepth = calculateProb(1 - costWithBestDepth);

% update distribution for current distribution.
% mapDistribution = (mapDistribution2 + mapDistribution1) * 0.5;
% mapDistribution = mapDistribution .* probWithBestDepth;
% mapDistribution = mapDistribution / sum(mapDistribution); %normalize
mapDistribution = probWithBestDepth / sum(probWithBestDepth); %normalize
