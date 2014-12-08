function [ depthMap, costMap] = DownToTop( image1_struct, otherImage_struct, depthMap,mapDistribution,  costMap, halfWindowSize, near, far,sigma,prob)

h = image1_struct.h;
w = image1_struct.w;
randMap = rand(h, w) * (far - near) + near;

emptyMap = zeros(size(depthMap));
tic
fprintf(1, 'starting down to top...\n');

parfor col = 1:w
  %  fprintf(1, 'col: %d\n', col);
    mapDistributionOneCol = mapDistribution(:,col,:);
    costMapOneCol = costMap(:,col,:);
    [emptyMap(:, col), costMap(:,col,:)] = routine_DownTop(randMap, mapDistributionOneCol, costMapOneCol, image1_struct, otherImage_struct, depthMap, col, halfWindowSize,sigma,prob);    
end
fprintf(1, 'elapsed time is %f', toc);
depthMap = emptyMap;

end

%  using the old depth, to compute the forward message, and then use that
%  to update the depth, and then update the forward message. compute the
%  probability,

function [oneCol, costMapOneCol] = routine_DownTop(randMap, mapDistributionOneCol, costMapOneCol, image1_struct, otherImage_struct, depthMap, col, halfWindowSize,sigma,prob)
    [h,w,~] = size(image1_struct.imageData);
    numOfSourceImgs = numel(otherImage_struct);
%     updatedCost = zeros(h, 1, numOfSourceImgs);
%      updatedCost(h,1,:) = costMapOneCol(h,1,:);

    constant = 2/sqrt(2*pi)/sigma/ erf(sqrt(2)/sigma);
    transitionProb = [prob,1-prob; 1-prob, prob];
    emission = constant * exp( -( 1-costMapOneCol(w,1,:) ).^2/(2*sigma*sigma) ); %compute the cost of 1st variable
    emission_uniform = 0.5;
    alpha = [emission; repmat(emission_uniform,size(emission)) ]; alpha = alpha./repmat((alpha(1,:,:) + alpha(2,:,:)), 2, 1);

    for row = h-1 : -1 : 1
%       compute alpha, and compute probability, and then update depth

        emission = constant * exp( -( 1-costMapOneCol(row,1,:) ).^2/(2*sigma*sigma) ); 
        alpha_new = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
            emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha_new = alpha_new./ repmat((alpha_new(1,:,:) + alpha_new(2,:,:)), [2,1,1] );
        forward_backward_prob = [alpha_new .* [mapDistributionOneCol(row,1,:); 1-mapDistributionOneCol(row,1,:)] ];        
        distribution = forward_backward_prob(1,:,:) ./ (forward_backward_prob(1,:,:) + forward_backward_prob(2,:,:));
        
% ---------------------------------------------------------------------------------------
        rowStart = min(h, row + halfWindowSize); rowEnd = max(1, row - halfWindowSize);
        colStart = max(1, col - halfWindowSize); colEnd = min(w, col + halfWindowSize);
 %  ----------------------------- Get the color of the reference image
        data1 = image1_struct.imageData(rowStart:-1:rowEnd, colStart:colEnd, :); 
        data1 = data1(:);
%          ------------------------
        [meshX, meshY] = meshgrid(colStart:colEnd, rowStart:-1:rowEnd); meshX = meshX(:); meshY = meshY(:);

        numOfElem = (rowStart - rowEnd + 1) *(  colEnd - colStart + 1);
        depthData = zeros( numOfElem, 3);   
        depthData(:, 1) = depthMap(row + 1, col);
        depthData(:, 2) = randMap(row,col);         
        depthData(:, 3) = depthMap(row, col);       
% -------------------------------------------------------------------------
        [bestDepth, costWithBestDepth] = costCalculationGiveId(costMapOneCol(row,1,:), meshX, meshY, depthData, image1_struct, otherImage_struct,  data1,...
            distribution);
        costMapOneCol(row,1,:) = reshape(costWithBestDepth, 1, 1, numOfSourceImgs);
        depthMap(row, col) = bestDepth;   
        
  %       update alpha      
        emission = constant * exp( -( 1-costMapOneCol(row,:,:) ).^2/(2*sigma*sigma) );
        alpha = [emission .* (alpha(1,:,:) * transitionProb(1,1) + alpha(2,:,:) * transitionProb(2,1));...
              emission_uniform .* (alpha(1,:,:)*transitionProb(1,2) + alpha(2,:,:) * transitionProb(2,2))];
        alpha = alpha./ repmat((alpha(1,:,:) + alpha(2,:,:)), [2,1,1] );
        
    end
    oneCol = depthMap(:,col);
    
end

