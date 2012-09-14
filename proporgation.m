function depthMap = proporgation(image1_struct, image2_struct, depthMap, flag, width)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        depthMap = LeftToRight(image1_struct, image2_struct, depthMap,  width);
    case (1)
        depthMap = RightToLeft(image1_struct, image2_struct, depthMap,  width);
    case (2)
        depthMap = TopToDown(image1_struct, image2_struct, depthMap,  width);
    case (3)
        depthMap = DownToTop(image1_struct, image2_struct, depthMap,  width);
    otherwise
        fprintf(1, 'proporgation direction is not recognized');
end
end




        