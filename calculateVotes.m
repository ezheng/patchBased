function bestDepthID = calculateVotes(allCostWithNan, idSelected)

% allCost = allCostWithNan(~any(isnan(allCostWithNan),2), :);
% 
% maxCost = max(allCost, [], 2);
% 
% allVotes = zeros(size(allCost));
% allVotes(allCost == repmat(maxCost, [1, size(allCost,2)])) = 1;
% 
% [~, bestDepthID] = max( sum(allVotes) );


votes = zeros(1,3);

for i = 1: numel(idSelected)
   cost = mean(allCostWithNan(idSelected{i},:));
   assert( all(~isnan(cost)));
   maxCost = max(cost); 
   votes = votes + (maxCost == cost);    
end

[~, bestDepthID] = max( votes );


