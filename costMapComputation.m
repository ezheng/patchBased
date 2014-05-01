function costMapComputation = costMapComputation(depthMap, img1_struct, otherImage_struct, halfWindowSize, isUseColor)

costMapComputation = zeros( size(depthMap,1), size(depthMap,2), numel(otherImage_struct) );

    
    parfor row = 1: size(depthMap,1)        
        costMapComputation(row,:,:) = costMapComputation_route(row, depthMap, img1_struct, otherImage_struct, halfWindowSize, isUseColor);
    end       



end


function costColumn = costMapComputation_route(row, depthMap, image1_struct, otherImage_struct, halfWindowSize, isUseColor)
    [h,w] = size(depthMap);       
    costColumn = zeros(1, size(depthMap,2), numel(otherImage_struct));
    
    for col = 1:size(depthMap, 2)
        colStart = max(1, col - halfWindowSize); colEnd = min(w, col + halfWindowSize);
        rowStart = max(1, row - halfWindowSize); rowEnd = min(h, row + halfWindowSize);
        
        numOfElem = (rowEnd - rowStart + 1) * (colEnd - colStart + 1);
        depthData = ones(numOfElem, 1) * depthMap(row,col);
        
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart:colEnd,:);
        data1 = data1(:);
        
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);
        
        for i = 1: size(costColumn,3)
            data2 = fetchColor( meshX, meshY, depthData ,image1_struct, otherImage_struct(i) );
            costColumn(1,col,i) = computeZNCC( data1, data2, isUseColor);
        end
        
    end
end
