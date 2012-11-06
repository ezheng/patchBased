
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
   cost = mean(allCostWithNan(idSelected{i},:),1);
   assert( all(~isnan(cost)));
   maxCost = max(cost); 
   votes = votes + (maxCost == cost);    
end

[maxVotes, bestDepthID] = max( votes );

% id = find(votes == maxVotes);
% if(numel(id) ~= 1)
% %     calculate mean
% %     allCostWithoutNan = allCostWithNan(~isnan(allCostWithNan));
%     allCostWithoutNan = allCostWithNan(~any(isnan(allCostWithNan), 2), :);
%     
% %     allCostWithoutNan(allCostWithoutNan == -1) = 0;
%     
%     allCostWithoutNan = mean(allCostWithoutNan, 1);
%     allCostWithoutNan = allCostWithoutNan(id);
%     [~, maxId] = max(allCostWithoutNan, [], 2);
%     bestDepthID = id(maxId);
% end



