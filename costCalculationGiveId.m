% function cost = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct,  data1)
function  [bestDepth, mapDistribution] = costCalculationGiveId(meshX, meshY, depthData,...
    image1_struct, otherImage_struct, data1, mapDistribution1, mapDistribution2, mapDistribution3, mapDistribution4, mapDistribution5,...
    gaussianTable, annealing)

% propogate distribution:

if(annealing >1)
    mapDistribution1 = mapDistribution2 * 0.2 + mapDistribution1 * 0.8;
    numOfSample = 3;    
else
    numOfSample = 1;
end
% mapDistribution2 = mapDistribution1;


% allCost = zeros(1,3);   % cost for 3 different depth. Only the id with best depth are used for distribution update

if( size(image1_struct.imageData,3) == 1)
    isUseColor = false;
else
    isUseColor = true;
end
% draw id from random distribution. The current distribution and the left distribution
 
% idSelected{1} = drawSample( (mapDistribution1 + mapDistribution2)*0.5, numOfSample);
idSelected{1} = drawSample( mapDistribution1, numOfSample);
% idSelected{1} = drawSample( mapDistribution2, numOfSample);
% idSelected{3} = drawSample( mapDistribution3, numOfSample);
% idSelected{4} = drawSample( mapDistribution4, numOfSample);
% idSelected{5} = drawSample( mapDistribution5, numOfSample);

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

% bestDepthID = calculateVotes(allCost, idSelected);

% if any(allCost(:) <= -0.95)
%    allCost % allCost reach to very high value
% end
% allProb = lookUpGaussiangTable( 1 - allCost, gaussianTable);

% 
% -------------------------------------------------------------------------
% find best depth

%  cost = zeros(numel(idSelected), 1); maxIdx = zeros(numel(idSelected), 1);
%  [~,IA,~] = intersect(idSelected, idSelected1);
%  [cost(1), maxIdx(1)] = max(mean(allCost(idSelected{1},:),1),[], 2);    
%  [~,IA,~] = intersect(idSelected, idSelected2);
%  [cost(2), maxIdx(2)] = max(mean(allCost(idSelected{2},:),1),[], 2);
%  for i = 1:numel(idSelected)
%      [~,IA,~] = intersect(idSelected, idSelected1);
%      [cost(i), maxIdx(i)] = max(mean(allCost(idSelected{i},:),1),[], 2);
%  end

% allCostWithoutNan = allCost(~any(isnan(allCost), 2), :);

allCostWithoutNan = allCost(idSelected{1},:);
[~, bestDepthID] = max(mean(allCostWithoutNan,1), [], 2);
%  [~, maxCostIdx ] = max(cost);
%  switch( maxIdx(maxCostIdx))
switch(bestDepthID)
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

costWithBestDepth = allCost(:, bestDepthID);
nonTestedId = find(isnan(costWithBestDepth));
for i = 1:numel(nonTestedId)
    idx= nonTestedId(i);
    data2 = fetchColor( meshX, meshY, depthData(:,bestDepthID), image1_struct, otherImage_struct(idx));
    costWithBestDepth(idx) = computeZNCC(data1, data2, isUseColor);
end

probWithBestDepth = calculateProb(1 - costWithBestDepth);

% update distribution for current distribution.
% mapDistribution = (mapDistribution2 + mapDistribution1) * 0.5;
% mapDistribution = mapDistribution .* probWithBestDepth;
% mapDistribution = mapDistribution / sum(mapDistribution); %normalize
mapDistribution = probWithBestDepth / sum(probWithBestDepth); %normalize
