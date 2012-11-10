function [orientationMap, depthMap, mapDistribution] = RightToLeft(orientationMap, image1_struct, otherImage_struct, depthMap, mapDistribution, rowWidth, annealing, isUseMex)

global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
emptyMapDistribution = zeros(size(mapDistribution));
% tic;

if(isUseMex)
    tic
    [depthMap, mapDistribution, orientationMap] = patchMatch(image1_struct, otherImage_struct, depthMap, randMap, mapDistribution, 2, orientationMap, annealing);
%     for i = 1:size(mapDistribution, 3)
% %       mapDistribution(:,:,i) = imfilter(mapDistribution(:,:,i), myfilter);        
%         mapDistribution(:,:,i) = medfilt2(mapDistribution(:,:,i), [9 9]);
%     end   
    mapDistribution = filterProbabilityMap(mapDistribution);
    toc
else
    parfor row = 1:h
        % for row = 1:h
        %     [emptyMap(row, :), emptyMapDistribution(row,:,:)] = routine_RightLeft(randMap,  mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
        %     fprintf('row %d is finished\n', row);
        if(row == h)
            [emptyMap(row, :), emptyMapDistribution(row,:,:) ] = routine_RightLeft(randMap, mapDistribution(row - 1,:,:), mapDistribution(row,:,:),  mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
        elseif(row == 1)
            [emptyMap(row, :), emptyMapDistribution(row,:,:) ] = routine_RightLeft(randMap, mapDistribution(row, :, :),   mapDistribution(row + 1, :, :), mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
        else
            [emptyMap(row, :), emptyMapDistribution(row,:,:) ] = routine_RightLeft(randMap, mapDistribution(row - 1,:,:), mapDistribution(row + 1,:,:), mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
        end
    end
    % t = toc;
    % fprintf(1, 'elapsed time is %f', t);
    depthMap = emptyMap;
    mapDistribution = emptyMapDistribution;
end
end

function [oneRow,mapDistribution_middle] = routine_RightLeft(randMap, mapDistribution_low, mapDistribution_high, mapDistribution_middle, image1_struct, otherImage_struct, depthMap,row, halfWindowSize, rowWidth, annealing)
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
% ----------------------------------------------------------------------------------------------------        
        mapDistribution1 = mapDistribution_middle(1, col + 1, :);
        mapDistribution1 = mapDistribution1(:);
        
        mapDistribution2 = mapDistribution_middle(1, col, :);
        mapDistribution2 = mapDistribution2(:);  
        
        if(col == 1)
            mapDistribution3 = mapDistribution_middle(1, col, :);
        else
            mapDistribution3 = mapDistribution_middle(1, col - 1, :);
        end
        mapDistribution3 = mapDistribution3(:);
        
        mapDistribution4 = mapDistribution_low(1, col, :);
        mapDistribution4 = mapDistribution4(:);
        
        mapDistribution5 = mapDistribution_high(1, col, :);
        mapDistribution5 = mapDistribution5(:);
% --------------------------------------------------------------------------
        [bestDepth, oneRowDistribution] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
            mapDistribution1, mapDistribution2, mapDistribution3, mapDistribution4, mapDistribution5, gaussianTable, annealing);
        depthMap(row, col) = bestDepth; 
        mapDistribution_middle(1,col,:) = reshape(oneRowDistribution, [1,1,numel(oneRowDistribution)]);
        
    end
    oneRow = depthMap(row,:);

end