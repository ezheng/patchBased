% function cost = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct,  data1)
function  [bestDepth,costWithBestDepth] = costCalculationGiveId(costMap, meshX, meshY, depthData,...
    image1_struct, otherImage_struct, data1, mapDistribution)

% propogate distribution:
numOfSample = 6;

idSelected = drawSample( mapDistribution, numOfSample);

allCost = NaN(numel(otherImage_struct), 3);
for j = 1:3    
    for k = 1:numel(idSelected)
        if(isnan(allCost(idSelected(k), j)))
            data2 = fetchColor( meshX, meshY, depthData(:,j) ,image1_struct, otherImage_struct(idSelected(k)));
            allCost(idSelected(k), j) = computeZNCC(data1, data2);
        end
    end    
end

allCostWithoutNan = allCost(idSelected,:);  %there can be repeated id in idSelected (based on monte carlo sampling)
[~, bestDepthID] = max(mean(allCostWithoutNan,1), [], 2);

bestDepth = depthData(1, bestDepthID);

testedId = find(~isnan(allCost(:,3)));
costMap = costMap(:);
assert(all( abs(allCost(testedId,3) - costMap(testedId)) < 0.0000000001 ));

costWithBestDepth = allCost(:, bestDepthID);
nonTestedId = find(isnan(costWithBestDepth));
for i = 1:numel(nonTestedId)
    idx= nonTestedId(i);
    data2 = fetchColor( meshX, meshY, depthData(:,bestDepthID), image1_struct, otherImage_struct(idx));
    costWithBestDepth(idx) = computeZNCC(data1, data2);
end


