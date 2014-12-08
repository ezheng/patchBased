function [ depthMap, costMap]= proporgation( image1_struct, image2_struct, depthMap,mapDistribution,costMap, flag, halfWindowSize, near, far,sigma,prob)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        [ depthMap, costMap] = LeftToRight( image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob);
    case (1)
        [  depthMap, costMap] = RightToLeft(  image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob);
    case (2)
        [  depthMap, costMap] = TopToDown(  image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob);
    case (3)
        [  depthMap, costMap] = DownToTop(  image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob);
    otherwise
        error(1, 'proporgation direction is not recognized');
end
end




        