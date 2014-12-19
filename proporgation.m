function [ depthMap, costMap, distribution]= proporgation( image1_struct, image2_struct, depthMap,mapDistribution,costMap, flag, halfWindowSize, near, far,sigma,prob,NCCDistribution)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        [ depthMap, costMap,distribution] = LeftToRight( image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob,NCCDistribution);
    case (1)
        [  depthMap, costMap,distribution] = RightToLeft(  image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob,NCCDistribution);
    case (2)
        [  depthMap, costMap,distribution] = TopToDown(  image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob,NCCDistribution);
    case (3)
        [  depthMap, costMap,distribution] = DownToTop(  image1_struct, image2_struct, depthMap, mapDistribution,costMap, halfWindowSize, near, far,sigma,prob,NCCDistribution);
    otherwise
        error(1, 'proporgation direction is not recognized');
end
end




        