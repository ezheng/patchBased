function [depthMap, mapDistribution] = LeftToRight(image1_struct, otherImage_struct, depthMap, mapDistribution, rowWidth, annealing)

global far; global near; global halfWindowSize;
% 
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
emptyMapDistribution = zeros(size(mapDistribution));

parfor row = 1:h          
% for row = 1:h          
    [emptyMap(row, :), emptyMapDistribution(row,:,:) ] = routine_LeftRight(randMap, mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
%     fprintf('row %d is finished\n', row);
end
depthMap = emptyMap;
mapDistribution = emptyMapDistribution;

end

function [oneRow, mapDistribution] = routine_LeftRight(randMap, mapDistribution, image1_struct, otherImage_struct, depthMap, row, halfWindowSize, rowWidth, annealing)
% mapDistribution: a cerntain row for all otherImage 

    [h,w,~] = size(image1_struct.imageData);
    gaussianTable = calculateGaussianTable();
    
    for col = 2:w    
%         if(col == 100)
%            col 
%         end
        colStart = max(1, col - halfWindowSize); colEnd = min(w, col + halfWindowSize);         
        rowStart = max(1, row - rowWidth); rowEnd = min(h, row + rowWidth);
%         ----------------------------------
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);          
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);
%         depthData = zeros(rowStart:rowEnd, colStart:colEnd);
        numOfElem = (rowEnd - rowStart + 1) * (colEnd - colStart + 1);        
        depthData = zeros( numOfElem, 3);   
        depthData(:,1) = depthMap(row, col-1);                  
        %         cost of the rand map                
        depthData(:,2) = randMap(row, col);
%         cost_2 = addBinaryCost( cost_2, depthData(1), depthMap(row, col - 1));
        depthData(:,3) = depthMap(row, col);

        mapDistribution1 = mapDistribution(1, col - 1, :);
        mapDistribution1 = mapDistribution1(:);
        mapDistribution2 = mapDistribution(1, col, :);
        mapDistribution2 = mapDistribution2(:);
        
        [bestDepth, oneRowDistribution] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
             mapDistribution1, mapDistribution2, gaussianTable, annealing);
        depthMap(row, col) = bestDepth;  
        mapDistribution(1,col,:) = reshape( oneRowDistribution, [1,1,numel(oneRowDistribution)]);
    end    
    oneRow = depthMap(row,:);   
%     oneRowMapDistribution = mapDistribution(row,:,:);

end