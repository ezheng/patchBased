function [depthMap, idMap ]= proporgation(image1_struct, image2_struct, depthMap,idMap, flag, width)

% flag:
% 0    left->right
% 1    right <-left
% 2    top -> down
% 3    down -> top
switch (flag)
    case (0)
        [depthMap, idMap] = LeftToRight(image1_struct, image2_struct, depthMap,idMap , width);
    case (1)
        [depthMap, idMap] = RightToLeft(image1_struct, image2_struct, depthMap,idMap,  width);
    case (2)
        [depthMap, idMap] = TopToDown(image1_struct, image2_struct, depthMap, idMap, width);
    case (3)
        [depthMap, idMap] = DownToTop(image1_struct, image2_struct, depthMap, idMap, width);
    otherwise
        fprintf(1, 'proporgation direction is not recognized');
end
end




        