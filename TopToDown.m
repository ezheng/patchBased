function depthMap = TopToDown(image1_struct, image2_struct, depthMap, colWidth)
if(nargin <4)
    colWidth = 0;
end
global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;
% begin few pixels
for col = 1:w
    for row = 2:halfWindowSize-1
%         propagate        
        depthMap(row, col) = depthMap(row-1, col);
%         cost of propagated depth
        colStart = max(1, col - colWidth); colEnd = min(w, col + colWidth);
        data1 = image1_struct.imageData(1:row, colStart:colEnd, :);
        data1 = data1(:);
%
        [meshX, meshY] = meshgrid(colStart:colEnd, 1:row); meshX = meshX(:); meshY = meshY(:);
        depthData = depthMap( 1:row, colStart:colEnd); 
        depthData = depthData(:);
        data2 = fetchColor(meshX, meshY, depthData,image1_struct, image2_struct );        
        cost_1 = computeZNCC(data1, data2);               
%         cost of the rand map ----------------------------------------------- 
        depthMap(row, col) = randMap(row, col);
        depthData = depthMap(1:row, colStart:colEnd); depthData = depthData(:);
        data3 = fetchColor(meshX, meshY, depthData,image1_struct, image2_struct );        
        cost_2 = computeZNCC(data1, data3);
        if(cost_2 < cost_1)
        	depthMap(row,col) = depthMap(row-1, col);
        end
    end
end    
% the remainning pixels
% if(matlabpool('size') ~=0)
%     matlabpool close;    
% end
% matlabpool open;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
tic;
parfor col = 1:w          
% for row = 1:h          
    emptyMap(:, col) = routine_TopDown(randMap, image1_struct, image2_struct, depthMap, col, localWindowSize, colWidth);    
    fprintf('row %d is finished\n', col);
end
t = toc;
fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;
% matlabpool close;

end

function oneCol = routine_TopDown(randMap, image1_struct, image2_struct, depthMap, col, halfWindowSize, colWidth)
    [h,w,~] = size(image1_struct.imageData);
    for row = halfWindowSize:h   
        start = row - halfWindowSize + 1;
        %         propagate
        depthMap(row, col) = depthMap(row-1, col);
        %         cost of propagated depth
        colStart = max(1, col - colWidth); colEnd = min(w, col + colWidth);        
%          data1 = image1_struct.imageData(rowStart:rowEnd, start:col, :); 
        data1 = image1_struct.imageData(start:row, colStart:colEnd, :); 
        data1 = data1(:);
%          ------------------------
        [meshX, meshY] = meshgrid([colStart:colEnd],start:row); meshX = meshX(:); meshY = meshY(:);
        depthData = depthMap(start:row, colStart:colEnd);
        depthData = depthData(:);
       
        data2 = fetchColor( meshX, meshY, depthData ,image1_struct, image2_struct );
        cost_1 = computeZNCC(data1, data2);
        %         cost of the rand map -----------------------------------------------
        depthMap(row, col) = randMap(row, col);
        depthData = depthMap(start:row, colStart:colEnd); depthData = depthData(:);
        data3 = fetchColor( meshX, meshY, depthData,image1_struct, image2_struct );
        cost_2 = computeZNCC(data1, data3);
        if(cost_2 < cost_1)        
            depthMap(row,col) = depthMap(row-1,col);
        else
            depthMap(row,col) = randMap(row,col);
        end
    end
    oneCol = depthMap(:,col);    
end

