function [depthMap, mapDistribution] = DownToTop(image1_struct, otherImage_struct, depthMap,mapDistribution,  colWidth, annealing)

global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
emptyMapDistribution = zeros(size(mapDistribution));

parfor col = 1:w          
% for col = 1:w
%     [emptyMap(:, col), emptyMapDistribution(:,col,:)] = routine_DownTop( randMap,mapDistribution(:,col,:), image1_struct, otherImage_struct, depthMap, col, localWindowSize, colWidth, annealing);    
%     fprintf('row %d is finished\n', col);
    if(col == w)
        [emptyMap(:, col), emptyMapDistribution(:,col,:)] = routine_DownTop(randMap, mapDistribution(:, col - 1, :),mapDistribution(:,col,:),mapDistribution(:,col,:), image1_struct, otherImage_struct, depthMap, col, localWindowSize, colWidth, annealing);    
    elseif(col == 1)
        [emptyMap(:, col), emptyMapDistribution(:,col,:)] = routine_DownTop(randMap, mapDistribution(:, col, :),mapDistribution(:,col + 1,:),mapDistribution(:,col,:), image1_struct, otherImage_struct, depthMap, col, localWindowSize, colWidth, annealing);    
    else
        [emptyMap(:, col), emptyMapDistribution(:,col,:)] = routine_DownTop(randMap, mapDistribution(:, col - 1, :),mapDistribution(:,col + 1,:), mapDistribution(:,col,:), image1_struct, otherImage_struct, depthMap, col, localWindowSize, colWidth, annealing);    
    end

end
% t = toc;
% fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;
mapDistribution = emptyMapDistribution;
end

function [oneCol, mapDistribution_middle] = routine_DownTop(randMap, mapDistribution_left, mapDistribution_right, mapDistribution_middle, image1_struct, otherImage_struct, depthMap, col, halfWindowSize, colWidth, annealing)
    [h,w,~] = size(image1_struct.imageData);
    gaussianTable = calculateGaussianTable();
    
    for row = h-1 : -1 : 1
        rowStart = min(h, row + halfWindowSize); rowEnd = max(1, row - halfWindowSize);
        colStart = max(1, col - colWidth); colEnd = min(w, col + colWidth);
%          data1 = image1_struct.imageData(rowStart:rowEnd, start:col, :); 
        data1 = image1_struct.imageData(rowStart:-1:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);
%           idSelected = [idMap(row+1, col), randImgIdx(row,col), idMap(row, col) ];
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:-1:rowEnd); meshX = meshX(:); meshY = meshY(:);
%         depthData = depthMap(rowStart:-1:rowEnd, colStart:colEnd);
%         depthData = zeros(rowStart:-1:rowEnd, colStart:colEnd);
%         numOfElem = zeros( rowStart - rowEnd + 1, colEnd - colStart + 1);        
%         depthData = depthData( numOfElem, 3);
        numOfElem = (rowStart - rowEnd + 1) *(  colEnd - colStart + 1);
        depthData = zeros( numOfElem, 3);   
        depthData(:, 1) = depthMap(row + 1, col);
%         [cost_1, id_1] = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct, idSelected, data1);        
%         data2 = fetchColor( meshX, meshY, depthData ,image1_struct, image2_struct );
%         cost_1 = computeZNCC(data1, data2);
        
        
        %         cost of the rand map -----------------------------------------------        
%         depthData = depthMap(rowStart:-1:rowEnd, colStart:colEnd); depthData = depthData(:);
        depthData(:, 2) = randMap(row,col);
%         [cost_2, id_2] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, idSelected, data1);
%         cost_2 = addBinaryCost( cost_2, depthData(1), depthMap(row + 1, col));
%         data3 = fetchColor( meshX, meshY, depthData,image1_struct, image2_struct );
%         cost_2 = computeZNCC(data1, data3);
%         
        depthData(:, 3) = depthMap(row, col);
       
%         data4 = fetchColor( meshX, meshY, depthData, image1_struct, image2_struct);
%         cost_3 = computeZNCC(data1, data4);   
% --------------------------------------------------------------------------
         mapDistribution1 = mapDistribution_middle(row + 1, 1 , :);
        mapDistribution1 = mapDistribution1(:);
        
        mapDistribution2 = mapDistribution_middle(row, 1, :);
        mapDistribution2 = mapDistribution2(:);

        if(row == 1)
            mapDistribution3 = mapDistribution_middle(row, 1, :);
        else
            mapDistribution3 = mapDistribution_middle(row - 1, 1, :);
        end
        mapDistribution3 = mapDistribution3(:);
        
        mapDistribution4 = mapDistribution_left(row, 1, :);
        mapDistribution4 = mapDistribution4(:);
        
        mapDistribution5 = mapDistribution_right(row, 1, :);
        mapDistribution5 = mapDistribution5(:);
        
% -------------------------------------------------------------------------
        [bestDepth, oneColDistribution] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct,  data1,...
            mapDistribution1, mapDistribution2, mapDistribution3, mapDistribution4, mapDistribution5, gaussianTable, annealing);
        
        depthMap(row, col) = bestDepth;
         mapDistribution_middle(row,1,:) = reshape( oneColDistribution, [1,1,numel(oneColDistribution)]);
    end
    oneCol = depthMap(:,col);

end


