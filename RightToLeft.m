function depthMap = RightToLeft(image1_struct, image2_struct, depthMap, rowWidth)
if(nargin <4)
    rowWidth = 0;
end
global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;



localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
tic;
parfor row = 1:h          
% for row = 1:h          
    emptyMap(row, :) = routine_RightLeft(randMap, image1_struct, image2_struct, depthMap, row, localWindowSize, rowWidth);    
    fprintf('row %d is finished\n', row);
end
t = toc;
fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;


end

function oneRow = routine_RightLeft(randMap, image1_struct, image2_struct, depthMap, row, halfWindowSize, rowWidth)
    [h,w,~] = size(image1_struct.imageData);
%     oneRow = zeros(1,w);
%     for col = halfWindowSize:w   
    for col = w-1 : -1 : 1
        colStart = min(w, col + halfWindowSize); colEnd = max(1, col - halfWindowSize);
        rowStart = max(1, row - rowWidth); rowEnd = min(h, row + rowWidth);
                
        data1 = image1_struct.imageData(rowStart:rowEnd, colStart: -1 :colEnd,:); 
        data1 = data1(:);
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:-1:colEnd, rowStart:rowEnd); meshX = meshX(:); meshY = meshY(:);
        depthData = depthMap(rowStart:rowEnd, colStart:-1:colEnd); 
        depthData = depthData(:);
        depthData(:) = depthMap(row, col+1);       
        data2 = fetchColor( meshX, meshY, depthData ,image1_struct, image2_struct );
        cost_1 = computeZNCC(data1, data2);        
        %         cost of the rand map -----------------------------------------------
        depthData = depthMap(rowStart:rowEnd, colStart:-1:colEnd); depthData = depthData(:);        
        depthData(:) = randMap(row, col);
        data3 = fetchColor( meshX, meshY, depthData,image1_struct, image2_struct );
        cost_2 = computeZNCC(data1, data3);
        if(cost_2 < cost_1)        
            depthMap(row,col) = depthMap(row,col+1);
        else
            depthMap(row,col) = randMap(row,col);
        end
    end
    oneRow = depthMap(row,:); 
end