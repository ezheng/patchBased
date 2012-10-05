function [depthMap, mapDistribution]= proporgation(image1_struct, image2_struct, depthMap,mapDistribution, flag, width)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        [depthMap, mapDistribution] = LeftToRight(image1_struct, image2_struct, depthMap, mapDistribution, width);
    case (1)
        [depthMap, mapDistribution] = RightToLeft(image1_struct, image2_struct, depthMap, mapDistribution, width);
    case (2)
        [depthMap, mapDistribution] = TopToDown(image1_struct, image2_struct, depthMap, mapDistribution, width);
    case (3)
        [depthMap, mapDistribution] = DownToTop(image1_struct, image2_struct, depthMap, mapDistribution, width);
    otherwise
        fprintf(1, 'proporgation direction is not recognized');
end
end




        