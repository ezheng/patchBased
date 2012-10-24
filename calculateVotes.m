function bestDepthID = calculateVotes(allCostWithNan)

allCost = allCostWithNan(~any(isnan(allCostWithNan),2), :);

maxCost = max(allCost, [], 2);

allVotes = zeros(size(allCost));
allVotes(allCost == repmat(maxCost, [1, size(allCost,2)])) = 1;

[~, bestDepthID] = max( sum(allVotes) );


