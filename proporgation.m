function [orientationMap, depthMap, costMap]= proporgation(orientationMap, image1_struct, image2_struct, depthMap,mapDistribution,costMap, flag, halfWindowSize)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        [orientationMap, depthMap, costMap] = LeftToRight(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize);
    case (1)
        [orientationMap, depthMap, costMap] = RightToLeft(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize);
    case (2)
        [orientationMap, depthMap, costMap] = TopToDown(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize);
    case (3)
        [orientationMap, depthMap, costMap] = DownToTop(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize);
    otherwise
        fprintf(1, 'proporgation direction is not recognized');
end
end




        