function distributionMap = distributionMapComputation(costMap, transProb, normalizer)

distributionMap = zeros( size(costMap) );

parfor row = 1: size(depthMap,1)
    distributionMap(row,:,:) = distributionMapComputation_route(costMap, transProb, normalizer, row);
end
end


function destributionMapARow = distributionMapComputation_route(costMap, transProb, normalizer, row)

    [~, width, numOfSourceImages] = size(costMap);
    
    
%     for 
    
    
%     for i = 1:width
%     
%     
%     end

%     compute the emission prob based on costMap
    
end

