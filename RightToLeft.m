function [depthMap, idMap] = RightToLeft(image1_struct, otherImage_struct, depthMap, idMap, rowWidth)
if(nargin <4)
    rowWidth = 0;
end
global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;
numOfOtherImages = numel(otherImage_struct);
randImgIdx = randi(numOfOtherImages, [h,w]);

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
emptyId = zeros(size(randMap));
% tic;
parfor row = 1:h          
% for row = 1:h          
    [emptyMap(row, :), emptyId(row,:)] = routine_RightLeft(randImgIdx, randMap, image1_struct, otherImage_struct, depthMap, idMap, row, localWindowSize, rowWidth);    
%     fprintf('row %d is finished\n', row);
end
% t = toc;
% fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;
idMap = emptyId;

end

function [oneRow,oneRowId] = routine_RightLeft(randImgIdx, randMap, image1_struct, otherImage_struct, depthMap,idMap, row, halfWindowSize, rowWidth)
    [h,w,~] = size(image1_struct.imageData);
%     oneRow = zeros(1,w);
%     for col = halfWindowSize:w   
    for col = w-1 : -1 : 1        
        colStart = min(w, col + halfWindowSize); colEnd = max(1, col - halfWindowSize);
        rowStart = max(1, row - rowWidth); rowEnd = min(h, row + rowWidth);
                
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart: -1 :colEnd,:); 
        data1 = data1(:);
        idSelected = [idMap(row, col + 1), randImgIdx(row,col), idMap(row, col) ];
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:-1:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);
        depthData = depthMap(rowStart:rowEnd, colStart:-1:colEnd); 
        depthData = depthData(:);
        depthData(:) = depthMap(row, col+1);       
%         data2 = fetchColor( meshX, meshY, depthData ,image1_struct, image2_struct );
%         cost_1 = computeZNCC(data1, data2);      
        [cost_1, id_1] = costCalculationGiveId(meshX, meshY, depthData ,image1_struct, otherImage_struct, idSelected, data1);

        %         cost of the rand map -----------------------------------------------
        depthData = depthMap(rowStart:rowEnd, colStart:-1:colEnd); depthData = depthData(:);        
        depthData(:) = randMap(row, col);
%         data3 = fetchColor( meshX, meshY, depthData,image1_struct, image2_struct );
%         cost_2 = computeZNCC(data1, data3);
        [cost_2, id_2] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, idSelected, data1);
        cost_2 = addBinaryCost( cost_2, depthData(1), depthData(row, col + 1));
%         
        depthData(:) = depthMap(row, col);
        [cost_3, id_3] = costCalculationGiveId(meshX, meshY, depthData, image1_struct, otherImage_struct, idSelected, data1);
        cost_3 = addBinaryCost( cost_3, depthData(1), depthData(row, col + 1));
%         data4 = fetchColor( meshX, meshY, depthData, image1_struct, image2_struct);
%         cost_3 = computeZNCC(data1, data4);        
        if(cost_3 < cost_1 || cost_3 < cost_2)   
            if(cost_2 < cost_1)
                depthMap(row,col) = depthMap(row,col+1);
                idMap(row, col) = id_1;
            else
                depthMap(row,col) = randMap(row,col);
                idMap(row, col) = id_2;                
            end
        else
            idMap(row,col) = id_3;
        end
    end
    oneRow = depthMap(row,:);
    oneRowId = idMap(row,:);
end