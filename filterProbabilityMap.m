function mapDistribution = filterProbabilityMap(mapDistribution)

windowSize = 11;
for i = 1:size(mapDistribution, 3)        
        mapDistribution(:,:,i) = medfilt2(mapDistribution(:,:,i), [windowSize windowSize]);
end   


    
% myfilter = fspecial('gaussian', 15, 3);
% for i = 1:size(mapDistribution, 3)
%     mapDistribution(:,:,i) = imfilter(mapDistribution(:,:,i), myfilter);
%     
%     
% end

