function [depthMap, mapDistribution] = RightToLeft(image1_struct, otherImage_struct, depthMap, mapDistribution, rowWidth)

global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
emptyMapDistribution = zeros(size(mapDistribution));
% tic;
parfor row = 1:h          
% for row = 1:h          
    [emptyMap(row, :), emptyMapDistribution(row,:,:)] = routine_RightLeft(randMap,  mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth);    
%     fprintf('row %d is finished\n', row);
end
% t = toc;
% fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;
mapDistribution = emptyMapDistribution;

end

function [oneRow,mapDistribution] = routine_RightLeft(randMap, mapDistribution, image1_struct, otherImage_struct, depthMap,row, halfWindowSize, rowWidth)
    [h,w,~] = size(image1_struct.imageData);
    gaussianTable = calculateGaussianTable();
%     oneRow = zeros(1,w);
%     for col = halfWindowSize:w   
    for col = w-1 : -1 : 1        
        colStart = min(w, col + halfWindowSize); colEnd = max(1, col - halfWindowSize);
        rowStart = max(1, row - rowWidth); rowEnd = min(h, row + rowWidth);
                
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart: -1 :colEnd,:); 
        data1 = data1(:);
%         idSelected = [idMap(row, col + 1), randImgIdx(row,col), idMap(row, col) ];
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:-1:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);
%         depthData = zeros(rowStart:rowEnd, colStart:-1:colEnd);    
        numOfElem = (rowEnd - rowStart + 1) * (colStart - colEnd + 1);
        depthData = zeros( numOfElem, 3);   
%         depthData = depthMap(rowStart:rowEnd, colStart:-1:colEnd);        
%         depthData = depthData(:);
        depthData(:, 1) = depthMap(row, col+1);       
        depthData(:, 2) = randMap(row, col);
        depthData(:, 3) = depthMap(row, col);
        
        mapDistribution1 = mapDistribution(1, col + 1, :);
        mapDistribution1 = mapDistribution1(:);
        mapDistribution2 = mapDistribution(1, col, :);
        mapDistribution2 = mapDistribution2(:);        
        
        [bestDepth, oneRowDistribution] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
            mapDistribution1, mapDistribution2, gaussianTable);
        depthMap(row, col) = bestDepth; 
        mapDistribution(1,col,:) = reshape( oneRowDistribution, [1,1,numel(oneRowDistribution)]);
        
    end
    oneRow = depthMap(row,:);

end