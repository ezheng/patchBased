function [depthMap, mapDistribution] = TopToDown(image1_struct, otherImage_struct, depthMap, mapDistribution, colWidth, annealing)

global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
emptyMapDistribution = zeros(size(mapDistribution));
% tic;
parfor col = 1:w          
% for col = 1:w          
    [emptyMap(:, col), emptyMapDistribution(:,col,:)] = routine_TopDown(randMap, mapDistribution(:,col,:), image1_struct, otherImage_struct, depthMap, col, localWindowSize, colWidth, annealing);    
%     fprintf('row %d is finished\n', col);
end
% t = toc;
% fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;
mapDistribution = emptyMapDistribution;

end

function [oneCol, mapDistribution] = routine_TopDown(randMap, mapDistribution, image1_struct, otherImage_struct, depthMap, col, halfWindowSize, colWidth, annealing)
    [h,w,~] = size(image1_struct.imageData);
    gaussianTable = calculateGaussianTable();
    for row = 2:h   
        rowStart = max(1, row - halfWindowSize); rowEnd = min(h, row + halfWindowSize);
        colStart = max(1, col - colWidth); colEnd = min(w, col + colWidth);
%          data1 = image1_struct.imageData(rowStart:rowEnd, start:col, :); 
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);
%          idSelected = [idMap(row-1, col), randImgIdx(row,col), idMap(row, col) ];
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);
%         depthData = depthMap(rowStart:rowEnd, colStart:colEnd);
%          depthData = zeros(rowStart:rowEnd, colStart:colEnd);
        numOfElem = (rowEnd - rowStart + 1) * (colEnd - colStart + 1);
         depthData = zeros( numOfElem, 3);   
%         depthData = depthData(:);
        depthData(:,1) = depthMap(row-1, col);       
%         data2 = fetchColor( meshX, meshY, depthData ,image1_struct, image2_struct );
%         cost_1 = computeZNCC(data1, data2);
%         [cost_1, id_1] = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct, idSelected, data1);        
        
        %         cost of the rand map -----------------------------------------------        
%         depthData = depthMap(rowStart:rowEnd, colStart:colEnd); depthData = depthData(:);
        depthData(:,2) = randMap(row,col);
%         data3 = fetchColor( meshX, meshY, depthData,image1_struct, image2_struct );
%         cost_2 = computeZNCC(data1, data3);   
%         [cost_2, id_2] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, idSelected, data1);
%         cost_2 = addBinaryCost(cost_2, depthData(1), depthMap(row - 1, col));
%         cost of original depthValue:
        depthData(:,3) = depthMap(row, col);
%         data4 = fetchColor( meshX, meshY, depthData, image1_struct, image2_struct);
%         cost_3 = computeZNCC(data1, data4);
        mapDistribution1 = mapDistribution(row - 1, 1 , :);
        mapDistribution1 = mapDistribution1(:);
        mapDistribution2 = mapDistribution(row, 1, :);
        mapDistribution2 = mapDistribution2(:);

        [bestDepth, oneColDistribution] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, data1,...
            mapDistribution1, mapDistribution2, gaussianTable, annealing);
        depthMap(row, col) = bestDepth;
         mapDistribution(row,1,:) = reshape( oneColDistribution, [1,1,numel(oneColDistribution)]);
          
%          cost_3 = addBinaryCost(cost_3, depthData(1), depthMap(row - 1, col));
%         if(cost_3 < cost_1 || cost_3 < cost_2)            
%             if(cost_2 < cost_1)
%                 depthMap(row,col) = depthMap(row-1,col);
%                  idMap(row, col) = id_1;
%             else
%                 depthMap(row,col) = randMap(row,col);
%                  idMap(row, col) = id_2;
%             end
%         else
%             idMap(row,col) = id_3;
%         end
    end
    oneCol = depthMap(:,col);    
%     oneColId = idMap(:,col);
end