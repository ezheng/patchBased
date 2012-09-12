function depthMap = LeftToRight(image1_struct, image2_struct, depthMap)

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
        data1 = image1_struct.imageData(row, 1:col,:); data1 = data1(:)';
        data2 = fetchColor([1:col]', ones(col,1).* row, depthMap(row, 1:col)',image1_struct, image2_struct );        
        cost_1 = computeZNCC(data1, data2);               
%         cost of the rand map ----------------------------------------------- 
        depthMap(row, col) = randMap(row, col);
        data3 = fetchColor([1:col]', ones(col,1).* row, depthMap(row, 1:col)',image1_struct, image2_struct );        
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
    emptyMap(row, :) = routine_LeftRight(randMap, image1_struct, image2_struct, depthMap, row, localWindowSize);    
    fprintf('row %d is finished', row);
end
t = toc;
fprintf(1, 'elapsed time is %f', t);
depthMap = emptyMap;
matlabpool close;

end

function oneRow = routine_LeftRight(randMap, image1_struct, image2_struct, depthMap, row, halfWindowSize)
    [h,w,~] = size(image1_struct.imageData);
%     oneRow = zeros(1,w);
    for col = halfWindowSize:w

        start = col - halfWindowSize + 1;
        %         propagate
        depthMap(row, col) = depthMap(row, col-1);
        %         cost of propagated depth
        data1 = image1_struct.imageData(row, start:col);
        data2 = fetchColor( [start:col]', ones(halfWindowSize,1).* row, depthMap(row, start:col)',image1_struct, image2_struct );
        cost_1 = computeZNCC(data1, data2);
        %         cost of the rand map -----------------------------------------------
        depthMap(row, col) = randMap(row, col);
        data3 = fetchColor( [start:col]', ones(halfWindowSize,1).* row, depthMap(row, start:col)',image1_struct, image2_struct );
        cost_2 = computeZNCC(data1, data3);
        if(cost_2 < cost_1)
        %   depthMap(row,col) = depthMap(row, col - 1);
            depthMap(row, col) = depthMap(row,col-1);
        else
            depthMap(row,col) = randMap(row,col);
        end
    end
    oneRow = depthMap(row,:);
    
end



