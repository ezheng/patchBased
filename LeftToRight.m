function [orientationMap, depthMap, mapDistribution] = LeftToRight(orientationMap, image1_struct, otherImage_struct, depthMap, mapDistribution, rowWidth, annealing, isUseMex)

global far; global near; global halfWindowSize;
% 
h = image1_struct.h;
w = image1_struct.w;
% s = RandStream('mcg16807','Seed',0);
% RandStream.setDefaultStream(s);
randMap = rand(h, w) * (far - near) + near;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
emptyMapDistribution = zeros(size(mapDistribution));

if(isUseMex)
    tic
    [depthMap, mapDistribution, orientationMap] = patchMatch(image1_struct, otherImage_struct, depthMap, randMap, mapDistribution, 0, orientationMap, annealing);
    
%     myfilter = fspecial('gaussian', 3);
%     myfilter = fspecial('gaussian', 5, 1.5)
    for i = 1:size(mapDistribution, 3)
%         mapDistribution(:,:,i) = imfilter(mapDistribution(:,:,i), myfilter);
        
        mapDistribution(:,:,i) = medfilt2(mapDistribution(:,:,i), [9 9]);
    end    
    toc
else
    parfor row = 1:h
%     for row = 1:h
        if(row == h)
            [emptyMap(row, :), emptyMapDistribution(row,:,:) ] = routine_LeftRight(randMap, mapDistribution(row - 1,:,:), mapDistribution(row,:,:),  mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
        elseif(row == 1)
            [emptyMap(row, :), emptyMapDistribution(row,:,:) ] = routine_LeftRight(randMap, mapDistribution(row, :, :),   mapDistribution(row + 1, :, :),   mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
        else
            [emptyMap(row, :), emptyMapDistribution(row,:,:) ] = routine_LeftRight(randMap, mapDistribution(row - 1,:,:), mapDistribution(row + 1,:,:), mapDistribution(row,:,:), image1_struct, otherImage_struct, depthMap, row, localWindowSize, rowWidth, annealing);
        end
        %     fprintf('row %d is finished\n', row);
    end
    depthMap = emptyMap;
    mapDistribution = emptyMapDistribution;
end

end


function [oneRow, mapDistribution_middle] = routine_LeftRight(randMap, mapDistribution_low, mapDistribution_high, mapDistribution_middle, image1_struct, otherImage_struct, depthMap, row, halfWindowSize, rowWidth, annealing)
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
% -------------------------------------------------------------------
        mapDistribution1 = mapDistribution_middle(1, col - 1, :);  % left
        mapDistribution1 = mapDistribution1(:); 
        
        mapDistribution2 = mapDistribution_middle(1, col, :); % middle
        mapDistribution2 = mapDistribution2(:); 
        if(col == w)
            mapDistribution3 = mapDistribution_middle(1, col, :);
        else
            mapDistribution3 = mapDistribution_middle(1, col + 1, :); % right
        end
        mapDistribution3 = mapDistribution3(:); 
        
        
        mapDistribution4 = mapDistribution_low(1, col, :); %top
        mapDistribution4 = mapDistribution4(:);
        
        mapDistribution5 = mapDistribution_high(1, col, :);
        mapDistribution5 = mapDistribution5(:);
% -------------------------------------------------------------------        
        [bestDepth, oneRowDistribution] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
             mapDistribution1, mapDistribution2, mapDistribution3, mapDistribution4, mapDistribution5 , gaussianTable, annealing);
        depthMap(row, col) = bestDepth;  
        mapDistribution_middle(1,col,:) = reshape( oneRowDistribution, [1,1,numel(oneRowDistribution)]);
    end    
    oneRow = depthMap(row,:);   
%     oneRowMapDistribution = mapDistribution(row,:,:);

end