function depthMap = LeftToRight(image1_struct, image2_struct, depthMap, rowWidth)
if(nargin <4)
    rowWidth = 0;
end
global far; global near; global halfWindowSize;
h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;
% begin few pixels
for row = 1:h
    for col = 2:halfWindowSize-1
%         propagate        
        depthMap(row, col) = depthMap(row, col-1);
%         cost of propagated depth
        rowStart = max(1, row - rowWidth); rowEnd = min(h, row + rowWidth);
        data1 = image1_struct.imageData(rowStart:rowEnd, 1:col,:); data1 = data1(:);
%               
        [meshX, meshY] = meshgrid([1:col], [rowStart:rowEnd]); meshX = meshX(:); meshY = meshY(:);
        depthData = depthMap(rowStart:rowEnd, 1:col); 
        depthData = depthData(:);
        data2 = fetchColor(meshX, meshY, depthData,image1_struct, image2_struct );        
        cost_1 = computeZNCC(data1, data2);               
%         cost of the rand map ----------------------------------------------- 
        depthMap(row, col) = randMap(row, col);
        depthData = depthMap(rowStart:rowEnd, 1:col); depthData = depthData(:);
        data3 = fetchColor(meshX, meshY, depthData,image1_struct, image2_struct );        
        cost_2 = computeZNCC(data1, data3);
        if(cost_2 < cost_1)
        	depthMap(row,col) = depthMap(row, col - 1);
        end
    end
end    
% the remainning pixels
if(matlabpool('size') ~=0)
    matlabpool close;    
end
matlabpool open;

localWindowSize = halfWindowSize;
emptyMap = zeros(size(depthMap));
tic;
 parfor row = 1:h          
% for row = 1:h          
    emptyMap(row, :) = routine_LeftRight(randMap, image1_struct, image2_struct, depthMap, row, localWindowSize, rowWidth);    
    fprintf('row %d is finished\n', row);
end
t = toc;
fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;
matlabpool close;

end

function oneRow = routine_LeftRight(randMap, image1_struct, image2_struct, depthMap, row, halfWindowSize, rowWidth)
    [h,w,~] = size(image1_struct.imageData);
%     oneRow = zeros(1,w);
    for col = halfWindowSize:w   
        start = col - halfWindowSize + 1;
        %         propagate
        depthMap(row, col) = depthMap(row, col-1);
        %         cost of propagated depth
        rowStart = max(1, row - rowWidth); rowEnd = min(h, row + rowWidth);
         data1 = image1_struct.imageData(rowStart:rowEnd, start:col); data1 = data1(:);
%          ------------------------
        [meshX, meshY] = meshgrid([start:col], [rowStart:rowEnd]); meshX = meshX(:); meshY = meshY(:);
        depthData = depthMap(rowStart:rowEnd, start:col); 
        depthData = depthData(:);
        
       
        data2 = fetchColor( meshX, meshY, depthData ,image1_struct, image2_struct );
        cost_1 = computeZNCC(data1, data2);
        %         cost of the rand map -----------------------------------------------
        depthMap(row, col) = randMap(row, col);
        depthData = depthMap(rowStart:rowEnd, start:col); depthData = depthData(:);        
        data3 = fetchColor( meshX, meshY, depthData,image1_struct, image2_struct );
        cost_2 = computeZNCC(data1, data3);
        if(cost_2 < cost_1)
        %   depthMap(row,col) = depthMap(row, col - 1);
            depthMap(row,col) = depthMap(row,col-1);
        else
            depthMap(row,col) = randMap(row,col);
        end
    end
    oneRow = depthMap(row,:);
    
end



