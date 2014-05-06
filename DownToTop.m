function [orientationMap, depthMap, costMap] = DownToTop(orientationMap, image1_struct, otherImage_struct, depthMap,mapDistribution,  costMap, halfWindowSize)

global far; global near; 
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

emptyMap = zeros(size(depthMap));
tic
fprintf(1, 'starting down to top...\n');
parfor col = 1:w
    fprintf(1, 'col: %d\n', col);
    mapDistributionOneCol = mapDistribution(:,col,:);
    costMapOneCol = costMap(:,col,:);
    [emptyMap(:, col), updateCost] = routine_DownTop(randMap, mapDistributionOneCol, costMapOneCol, image1_struct, otherImage_struct, depthMap, col, halfWindowSize);
    costMap(:,col,:) = updateCost;
end
fprintf(1, 'elapsed time is %f', toc);
depthMap = emptyMap;

end


function [oneCol, updatedCost] = routine_DownTop(randMap, mapDistributionOneCol, costMapOneCol, image1_struct, otherImage_struct, depthMap, col, halfWindowSize)
    [h,w,~] = size(image1_struct.imageData);
    numOfSourceImgs = numel(otherImage_struct);
    updatedCost = zeros(h, 1, numOfSourceImgs);
     updatedCost(h,1,:) = costMapOneCol(h,1,:);
    for row = h-1 : -1 : 1
        rowStart = min(h, row + halfWindowSize); rowEnd = max(1, row - halfWindowSize);
        colStart = max(1, col - halfWindowSize); colEnd = min(w, col + halfWindowSize);
 %  ----------------------------- Get the color of the reference image
        data1 = image1_struct.imageData(rowStart:-1:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:-1:rowEnd); meshX = meshX(:); meshY = meshY(:);

        numOfElem = (rowStart - rowEnd + 1) *(  colEnd - colStart + 1);
        depthData = zeros( numOfElem, 3);   
        depthData(:, 1) = depthMap(row + 1, col);
        depthData(:, 2) = randMap(row,col);         
        depthData(:, 3) = depthMap(row, col);
       
% -------------------------------------------------------------------------
        [bestDepth, costWithBestDepth] = costCalculationGiveId(costMapOneCol(row,1,:), meshX, meshY, depthData, image1_struct, otherImage_struct,  data1,...
            mapDistributionOneCol(row,1,:));
        updatedCost(row, 1, :) = reshape(costWithBestDepth, 1, 1, numOfSourceImgs);
        depthMap(row, col) = bestDepth;         
    end
    oneCol = depthMap(:,col);
end

