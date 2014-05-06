function [orientationMap, depthMap, costMap] = LeftToRight(orientationMap, image1_struct, otherImage_struct, depthMap, mapDistribution, costMap, halfWindowSize)

global far; global near;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

emptyMap = zeros(size(depthMap));
tic
fprintf(1, 'starting left to right...\n');
parfor row = 1:h
% for row = 1:h
    fprintf(1, 'row: %d\n', row);
    mapDistributionOneRow = mapDistribution(row,:,:);        
    costMapOneRow = costMap(row,:,:);    
    [emptyMap(row, :), updatedCost]=routine_LeftRight(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize);    
    costMap(row,:,:) = updatedCost;
end
fprintf(1, 'elapsed time is %f', toc);
depthMap = emptyMap;

end

function [oneRow,updatedCost] = routine_LeftRight(randMap, mapDistributionOneRow, costMapOneRow, image1_struct, otherImage_struct, depthMap, row, halfWindowSize)
    [h,w,~] = size(image1_struct.imageData);   
    numOfSourceImgs = numel(otherImage_struct);
    updatedCost = zeros(1, w, numOfSourceImgs);
    updatedCost(1,1,:) = costMapOneRow(1,1,:);
    for col = 2:w    
        colStart = max(1, col - halfWindowSize); colEnd = min(w, col + halfWindowSize);         
        rowStart = max(1, row - halfWindowSize); rowEnd = min(h, row + halfWindowSize);
%       ----------------------------- Get the color of the reference image
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);
%        ------------------------ Generate the depth candidate
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);

        numOfElem = (rowEnd - rowStart + 1) * (colEnd - colStart + 1);        
        depthData = zeros( numOfElem, 3);   
        depthData(:,1) = depthMap(row, col-1); 
        depthData(:,2) = randMap(row, col);
        depthData(:,3) = depthMap(row, col);    % the 3rd column is current depth.       
%       ------------------------- compute the cost and generate the best depth given
        [bestDepth,costWithBestDepth] = costCalculationGiveId(costMapOneRow(1,col,:), meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
             mapDistributionOneRow(1,col,:) );
        updatedCost(1,col,:) = reshape(costWithBestDepth, 1,1,numOfSourceImgs);
        depthMap(row, col) = bestDepth;
        
    end
    oneRow = depthMap(row,:);   
    
end