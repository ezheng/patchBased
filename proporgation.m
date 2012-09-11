function depthMap = proporgation(image1_struct, image2_struct, depthMap, flag)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        depthMap = LeftToRight(image1_struct, image2_struct, depthMap);
    case (1)
        depthMap = RightToLight(image1_struct, image2_struct, depthMap);
    case (2)
        depthMap = TopToDown(image1_struct, image2_struct, depthMap);
    case (3)
        depthMap = DownToTop(image1_struct, image2_struct, depthMap);
    otherwise
        fprintf(1, 'proporgation direction is not recognized');
end
end




        