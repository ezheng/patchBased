function [orientationMap, depthMap, mapDistribution]= proporgation(orientationMap, image1_struct, image2_struct, depthMap,mapDistribution, flag, width, annealing, isUseMex)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        [orientationMap, depthMap, mapDistribution] = LeftToRight(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution, width, annealing, isUseMex);
    case (1)
        [orientationMap, depthMap, mapDistribution] = RightToLeft(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution, width, annealing, isUseMex);
    case (2)
        [orientationMap, depthMap, mapDistribution] = TopToDown(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution, width, annealing, isUseMex);
    case (3)
        [orientationMap, depthMap, mapDistribution] = DownToTop(orientationMap, image1_struct, image2_struct, depthMap, mapDistribution, width, annealing, isUseMex);
    otherwise
        fprintf(1, 'proporgation direction is not recognized');
end
end




        